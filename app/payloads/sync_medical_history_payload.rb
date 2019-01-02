class SyncMedicalHistoryPayload
  attr_reader :patient, :user_id

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  def initialize(patient, user_id)
    @patient = patient
    @user_id = user_id
  end

  def parse_boolean_as_enum(value)
    boolean_value = value || false
    boolean_value ? 'yes' : 'unknown'
  end

  def to_payload
    { id: patient.medical_history_uuid,
      patient_id: patient.patient_uuid,
      prior_heart_attack: parse_boolean_as_enum(patient.prior_heart_attack),
      prior_stroke: parse_boolean_as_enum(patient.prior_stroke),
      chronic_kidney_disease: parse_boolean_as_enum(patient.chronic_kidney_disease),
      receiving_treatment_for_hypertension: parse_boolean_as_enum(patient.already_on_treatment),
      diagnosed_with_hypertension: parse_boolean_as_enum(patient.diagnosed_with_hypertension),
      diabetes: parse_boolean_as_enum(nil), # This information is not present in the red cards
      created_at: patient.registered_on_without_timestamp,
      updated_at: Time.now }
  end
end