require 'net/http'

class SyncService
  attr_reader :request_key, :host, :user_id, :access_token, :facility_uuid

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(host, user_id, access_token, facility_uuid)
    @host = host
    @user_id = user_id
    @access_token = access_token
    @facility_uuid = facility_uuid
  end

  def sync_all(patients_to_sync)
    visits_to_sync = Visit.where(patient: patients_to_sync).select(&:unsynced?)
    begin
      sync('patients', patients_to_sync, SyncPatientPayload)
      sync('blood_pressures', visits_to_sync, SyncBloodPressurePayload)
      sync('medical_histories', patients_to_sync, SyncMedicalHistoryPayload)
      sync('appointments', patients_to_sync, SyncAppointmentPayload)
      sync('prescription_drugs', patients_to_sync, SyncPrescriptionDrugPayload)
    rescue
      raise SyncError, "Error while syncing to Simple Server!"
    end
  end

  private

  def sync(request_key, records, request_payload)
    request = to_request(records, request_payload)
    response = api_post("api/v2/#{request_key.to_s}/sync", Hash[request_key.to_sym, request])

    error_ids = JSON(response.body)['errors'].map { |error| error['id'] }
    success_ids = request.map { |record| record[:id] }.reject { |id| error_ids.include?(id) }

    sync_log_hash = { simple_model: request_key.to_s.singularize.camelcase, synced_at: Time.now }

    success_ids.each { |id| SyncLog.create(sync_log_hash.merge(simple_id: id, sync_errors: nil)) }
    JSON(response.body)['errors'].map { |error| SyncLog.create(sync_log_hash.merge(simple_id: error['id'], sync_errors: error)) }
  end

  def to_request(records, request_payload)
    requests = records.flat_map do |record|
      begin
        request_payload.new(record, user_id).to_payload
      rescue
        nil
      end
    end
    requests.compact
  end

  def api_post(path, request_body)
    uri = URI.parse(host + path)
    header = { 'Content-Type' => 'application/json',
               'ACCEPT' => 'application/json',
               'X-USER-ID' => user_id,
               'X-FACILITY-ID' => facility_uuid,
               'Authorization' => "Bearer #{access_token}" }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = ENV['USE_SSL'].present? ? ENV['USE_SSL'] == 'true' : true
    http.read_timeout = 1
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = request_body.to_json
    http.request(request)
  end
end