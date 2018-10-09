require 'net/http'

class SyncMedicalHistoryService
  attr_reader :host, :user_id, :access_token

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze
  ERROR_FILE_PREFIX = 'medical-history-errors-'

  def initialize(host, user_id, access_token)
    @host = host
    @user_id = user_id
    @access_token = access_token
  end

  def api_post(path, request_body)
    uri = URI.parse(host + path)
    header = { 'Content-Type' => 'application/json',
               'ACCEPT' => 'application/json',
               'X-USER-ID' => user_id,
               'Authorization' => "Bearer #{access_token}" }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 500
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = request_body.to_json
    http.request(request)
  end

  def sync
    request = Patient.all.map { |patient| to_request(patient) }
    response = api_post('api/v1/medical_histories/sync', { medical_histories: request })
    errors = JSON(response.body)['errors'].map do |error|
      Patient.find_by(medical_history_uuid: error['id']).attributes.merge(error: error.except('id'))
    end
    write_errors_to_file(errors)
  end

  def device_created_at(patient)
    patient.first_visit.try(:measured_on).strftime(TIME_WITHOUT_TIMEZONE_FORMAT) || Time.now
  end

  def parse_boolean(value)
    value || false
  end

  def to_request(patient)
    { id: patient.medical_history_uuid,
      patient_id: patient.patient_uuid,
      prior_heart_attack: parse_boolean(patient.prior_heart_attack),
      prior_stroke: parse_boolean(patient.prior_stroke),
      chronic_kidney_disease: parse_boolean(patient.chronic_kidney_disease),
      receiving_treatment_for_hypertension: parse_boolean(patient.already_on_treatment),
      diabetes: parse_boolean(nil), # This information is not present in the red cards
      created_at: device_created_at(patient),
      updated_at: Time.now }
  end

  def write_errors_to_file(errors)
    return unless errors.present?
    error_file = ERROR_FILE_PREFIX + Time.now.to_i.to_s + ".csv"
    CSV.open(error_file, "wb") do |csv|
      csv << errors.first.keys # adds the attributes name on the first line
      errors.each do |error|
        csv << error.values
      end
    end
  end
end