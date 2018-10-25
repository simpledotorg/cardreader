class SyncMedicalHistoryPayload
  attr_reader :patient, :user_id

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(patient, user_id)
    @patient = patient
    @user_id = user_id
  end

  def device_created_at
    begin
      patient.first_visit.try(:measured_on).strftime(TIME_WITHOUT_TIMEZONE_FORMAT) || now
    rescue => ex
      puts "Error getting patient first visit measure on date.", ex.message
    end
  end

  def parse_boolean(value)
    value || false
  end

  def to_payload
    { id: patient.medical_history_uuid,
      patient_id: patient.patient_uuid,
      prior_heart_attack: parse_boolean(patient.prior_heart_attack),
      prior_stroke: parse_boolean(patient.prior_stroke),
      chronic_kidney_disease: parse_boolean(patient.chronic_kidney_disease),
      receiving_treatment_for_hypertension: parse_boolean(patient.already_on_treatment),
      diagnosed_with_hypertension: parse_boolean(patient.diagnosed_with_hypertension),
      diabetes: parse_boolean(nil), # This information is not present in the red cards
      created_at: device_created_at,
      updated_at: Time.now }
  end
end