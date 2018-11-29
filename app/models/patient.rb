class Patient < ApplicationRecord
  belongs_to :facility, inverse_of: :patients
  has_many :visits, inverse_of: :patient, dependent: :destroy

  validates_date :registered_on

  validates :treatment_number, presence: true
  validates :treatment_number, uniqueness: {
    scope: :facility_id,
    message: "should be unique per facility",
    case_sensitive: false
  }

  TREATMENT_NUMBER_DIGITS = 8.freeze

  def formatted_treatment_number
    treatment_number_prefix + treatment_number.to_s
  end

  def treatment_number_prefix
    return "" unless treatment_number_needs_prefix?

    prefix = "2018-"
    prefix += "0" * [TREATMENT_NUMBER_DIGITS - treatment_number.to_s.length, 0].max

    prefix
  end

  def first_visit
    self.visits.order(:measured_on).limit(1).first
  end

  def registered_on_without_timestamp
    if first_visit.present?
      first_visit.measured_on_without_timestamp
    else
      Time.now
    end
  end

  def synced?
    sync_status == :synced
  end

  def sync_status
    return :unsynced unless latest_patient_sync_log.present?
    if latest_patient_sync_log.sync_errors.present?
      return :sync_errored
    elsif latest_patient_sync_log.synced_at > updated_at
      return :synced
    end
    :unsynced
  end

  private

  def treatment_number_needs_prefix?
    true if treatment_number.nil? || Integer(treatment_number) rescue false
  end

  def latest_patient_sync_log
    SyncLog.where(simple_id: patient_uuid, simple_model: 'Patient').order(synced_at: :desc).first
  end

  def latest_medical_history_sync_log
    SyncLog.where(simple_id: medical_history_uuid, simple_model: 'MedicalHistory').order(synced_at: :desc).first
  end
end
