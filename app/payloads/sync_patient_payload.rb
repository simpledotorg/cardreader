class SyncPatientPayload
  attr_reader :patient, :user_id

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(patient, user_id)
    @patient = patient
    @user_id = user_id
  end

  def to_payload
    { id: patient.patient_uuid,
      gender: simple_gender,
      full_name: patient.name.split(' ').map(&:humanize).join(' '),
      status: 'active',
      date_of_birth: nil,
      age: patient.age,
      age_updated_at: now,
      created_at: patient.registered_on_without_timestamp,
      updated_at: now,
      address: simple_address,
      phone_numbers: simple_phone_numbers
    }
  end

  private

  def simple_gender
    case patient.gender.strip
    when Set['M', 'Male']
      'male'
    when Set['F', 'Female']
      'female'
    when Set['T', 'Transgender']
      'transgender'
    end
  end

  def now
    Time.now
  end

  def simple_address
    { id: patient.address_uuid,
      street_address: [patient.house_number, patient.street_name].reject(&:blank?).join(', ').humanize,
      village_or_colony: [patient.area, patient.village].reject(&:blank?).join(', ').humanize,
      district: (patient.district || patient.facility.district.name).humanize,
      state: 'Punjab',
      country: 'India',
      pin: patient.pincode,
      created_at: patient.registered_on_without_timestamp,
      updated_at: now }
  end

  def simple_phone_numbers
    phone_numbers = []
    if patient.phone.present?
      phone_numbers << { id: patient.phone_uuid,
                         number: patient.phone,
                         phone_type: 'mobile',
                         active: true,
                         created_at: patient.registered_on_without_timestamp,
                         updated_at: now }
    end
    if patient.alternate_phone.present?
      phone_numbers << { id: patient.alternate_phone_uuid,
                         number: patient.alternate_phone,
                         phone_type: 'mobile',
                         active: true,
                         created_at: patient.registered_on_without_timestamp,
                         updated_at: now }
    end
    phone_numbers
  end
end