class SyncBloodPressurePayload
  attr_reader :visit, :user_id

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(visit, user_id)
    @visit = visit
    @user_id = user_id
  end

  def to_payload
    { id: visit.blood_pressure_uuid,
      systolic: visit.systolic,
      diastolic: visit.diastolic,
      created_at: visit.measured_on_without_timestamp,
      updated_at: visit.measured_on_without_timestamp,
      patient_id: visit.patient.patient_uuid,
      facility_id: visit.facility.simple_uuid,
      user_id: user_id }
  end
end