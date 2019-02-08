class SyncMedicalHistoryPayload
  attr_reader :patient, :user_id

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  BOOLEAN_TO_ENUM_MAP = {
    true => 'yes',
    false => 'no',
    nil => 'unknown'
  }.freeze

  def initialize(patient, user_id)
    @patient = patient
    @user_id = user_id
  end

  def to_payload
    { id: patient.medical_history_uuid,
      patient_id: patient.patient_uuid,
      prior_heart_attack: BOOLEAN_TO_ENUM_MAP[patient.prior_heart_attack],
      prior_stroke: BOOLEAN_TO_ENUM_MAP[patient.prior_stroke],
      chronic_kidney_disease: BOOLEAN_TO_ENUM_MAP[patient.chronic_kidney_disease],
      receiving_treatment_for_hypertension: BOOLEAN_TO_ENUM_MAP[patient.already_on_treatment],
      diagnosed_with_hypertension: BOOLEAN_TO_ENUM_MAP[patient.diagnosed_with_hypertension],
      diabetes: 'unknown', # This information is not present in the red cards
      created_at: patient.registered_on_without_timestamp,
      updated_at: patient.registered_on_without_timestamp,}
  end
end