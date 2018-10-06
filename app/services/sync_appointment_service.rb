require 'net/http'

class SyncAppointmentService
  attr_reader :host, :user_id, :access_token

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze
  ERROR_FILE_PREFIX = 'appointments-errors-'

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
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = request_body.to_json
    http.request(request)
  end

  def sync
    request = Patient.all.flat_map { |patient| to_requests(patient.visits.order(:measured_on)) }
    response = api_post('api/v1/appointments/sync', { appointments: request })
    errors = JSON(response.body)['errors'].map do |error|
      Visit.find_by(appointment_uuid: error['id']).attributes.merge(error: error.except('id'))
    end
    write_errors_to_file(errors)
  end

  def device_created_at(visit)
    visit.measured_on.strftime(TIME_WITHOUT_TIMEZONE_FORMAT)
  end

  def to_requests(visits)
    requests = visits.map { |visit| to_request(visit) }
    requests.last[:status] = 'scheduled'
    requests
  end

  def to_request(visit)
    { id: visit.appointment_uuid,
      patient_id: visit.patient.patient_uuid,
      facility_id: visit.facility.try(:simple_uuid),
      scheduled_date: visit.next_visit_on,
      status: 'visited',
      created_at: device_created_at(visit),
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