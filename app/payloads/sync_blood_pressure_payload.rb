class SyncBloodPressurePayload
  attr_reader :visit, :user_id

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(visit, user_id)
    @visit = visit
    @user_id = user_id
  end

  def device_created_at
    visit.measured_on.strftime(TIME_WITHOUT_TIMEZONE_FORMAT)
  end

  def to_request
    { id: visit.blood_pressure_uuid,
      systolic: visit.systolic,
      diastolic: visit.diastolic,
      created_at: device_created_at,
      updated_at: device_created_at,
      patient_id: visit.patient.patient_uuid,
      facility_id: visit.facility.try(:simple_uuid),
      user_id: user_id }
  end
end