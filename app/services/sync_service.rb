require 'net/http'

class SyncService
  attr_reader :request_key, :host, :user_id, :access_token, :sync_status

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(host, user_id, access_token)
    @host = host
    @user_id = user_id
    @access_token = access_token
    @sync_status = Hash[Patient, Hash[:synced_ids, [].to_set,
                                      :failed_id_to_errors_hash, Hash[]],
                        Visit, Hash[:synced_ids, [].to_set,
                                    :failed_id_to_errors_hash, Hash[]]]
  end

  def sync(patients_to_sync)
    visits_to_sync = Visit.where(patient: patients_to_sync).reject(&:synced?)

    sync_entity('patients', patients_to_sync, SyncPatientPayload, report_errors_on_class: Patient)
    sync_entity('blood_pressures', visits_to_sync, SyncBloodPressurePayload, report_errors_on_class: Visit)
    sync_entity('medical_histories', patients_to_sync, SyncMedicalHistoryPayload, report_errors_on_class: Patient)
    sync_entity('appointments', patients_to_sync, SyncAppointmentPayload, report_errors_on_class: Visit)
    sync_entity('prescription_drugs', patients_to_sync, SyncPrescriptionDrugPayload)

    mark_synced_and_failed()
  end

  def sync_entity(request_key, records, request_payload, report_errors_on_class: nil)
    begin
      request = to_request(request_key, records, request_payload)
      response = api_post("api/v1/#{request_key.to_s}/sync", Hash[request_key.to_sym, request])
      error_ids = JSON(response.body)['errors'].map { |error| error['id'] }
      success_ids = request.map { |record| record[:id] }.reject { |id| error_ids.include?(id) }
      if report_errors_on_class.present?
        uuid_field = "#{request_key.to_s.singularize}_uuid"
        success_ids.each do |id|
          synced_record = report_errors_on_class.find_by(uuid_field => id)
          sync_status[report_errors_on_class][:synced].add(synced_record.id)
        end
        JSON(response.body)['errors'].map do |error|
          failed_record = report_errors_on_class.find_by(uuid_field => error['id'])
          sync_status[report_errors_on_class][:failed_id_to_errors_hash][failed_record.id].to_a << error.except('id')
        end
      end
    rescue => error
      puts "Could not sync #{request_key}. Error: #{error.message}"
    end
  end

  def mark_synced_and_failed
    failed_patient_ids = sync_status[Patient][:failed_id_to_errors_hash].keys
    failed_patient_ids.each do |id|
      errors = sync_status[Patient][:failed_id_to_errors_hash][id]
      Patient.find(id).update_columns(last_sync_errors: errors)
    end

    synced_patient_ids = sync_status[Patient][:synced_ids] - failed_patient_ids
    synced_patient_ids.each do |id|
      Patient.find(id).update_columns(synced_at: Time.now, last_sync_errors: nil)
    end

    failed_visit_ids = sync_status[Visit][:failed_id_to_errors_hash].keys
    failed_visit_ids.each do |id|
      errors = sync_status[Visit][:failed_id_to_errors_hash][id]
      Visit.find(id).update_columns(last_sync_errors: errors)
    end

    synced_visit_ids = sync_status[Visit][:synced_ids] - failed_visit_ids
    synced_visit_ids.each do |id|
      Visit.find(id).update_columns(synced_at: Time.now, last_sync_errors: nil)
    end
  end

  def to_request(request_key, records, request_payload)
    requests = records.flat_map do |record|
      begin
        request_payload.new(record, user_id).to_payload
      rescue => error
        write_errors_to_file(request_key, [record.attributes.merge(error: [error.message])])
        nil
      end
    end
    requests.compact
  end

  private

  def error_file(request_key)
    "#{request_key}-errors-#{Date.today.iso8601}.csv"
  end

  def now
    Time.now
  end

  def api_post(path, request_body)
    uri = URI.parse(host + path)
    header = { 'Content-Type' => 'application/json',
               'ACCEPT' => 'application/json',
               'X-USER-ID' => user_id,
               'Authorization' => "Bearer #{access_token}" }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = ENV['USE_SSL'].present? ? ENV['USE_SSL'] == 'true' : true
    http.read_timeout = 500
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = request_body.to_json
    http.request(request)
  end
end