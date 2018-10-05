require 'net/http'

class SyncPatientService
  attr_reader :host, :user_id, :access_token

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

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
    Patient.all.each do |patient|
      response = api_post('api/v1/patients/sync', { patients: [to_request(patient)] })
      puts response['errors'] if response['errors'].present?
    end
  end

  def to_request(patient)
    { id: patient.patient_uuid,
      gender: to_simple_gender(patient.gender),
      full_name: patient.name,
      status: 'active',
      date_of_birth: nil,
      age: patient.age,
      age_updated_at: now,
      created_at: device_created_at(patient),
      updated_at: now,
      address: to_simple_address(patient),
      phone_numbers: to_simple_phone_numbers(patient)
    }
  end

  private

  def device_created_at(patient)
    patient.first_visit.try(:measured_on).strftime(TIME_WITHOUT_TIMEZONE_FORMAT) || now
  end

  def to_simple_gender(gender)
    case gender
    when Set['M']
      'male'
    when Set['F']
      'female'
    when Set['T']
      'transgender'
    end
  end

  def now
    Time.now
  end

  def to_simple_address(patient)
    { id: patient.address_uuid,
      street_address: [patient.house_number, patient.street_name].reject(&:blank?).join(', '),
      village_or_colony: '',
      district: patient.district || patient.facility.district.name,
      state: 'Punjab',
      country: 'India',
      pin: patient.pincode,
      created_at: device_created_at(patient),
      updated_at: now }
  end

  def to_simple_phone_numbers(patient)
    phone_numbers = []
    if patient.phone.present?
      phone_numbers << { id: patient.phone_uuid,
                         number: patient.phone,
                         created_at: device_created_at(patient),
                         updated_at: now }
    end
    if patient.alternate_phone.present?
      phone_numbers << { id: patient.alternate_phone_uuid,
                         number: patient.alternate_phone,
                         created_at: device_created_at(patient),
                         updated_at: now }
    end
    phone_numbers
  end
end