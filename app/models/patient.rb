class Patient < ApplicationRecord
  include SyncLoggable

  belongs_to :author, class_name: "User", foreign_key: "author_id"
  belongs_to :facility, inverse_of: :patients

  has_many :visits, inverse_of: :patient, dependent: :destroy

  validates_date :registered_on

  validates :treatment_number, presence: true
  validates :treatment_number, uniqueness: {
    scope: :facility_id,
    message: "should be unique per facility",
    case_sensitive: false
  }

  class << self
    include SyncLoggable

    def last_synced_at
      joins("INNER JOIN sync_logs ON sync_logs.simple_id = patients.patient_uuid")
        .where(sync_logs: { sync_errors: nil })
        .maximum('sync_logs.synced_at')
    end

    def highest_treatment_number
      pluck(:treatment_number)&.max_by(&:to_i)
    end

    def sync_statuses
      patients = all
      patient_uuids = patients.map(&:patient_uuid)
      grouped_sync_logs = latest_sync_logs(patient_uuids, 'Patient')
                            .group_by(&:simple_id)

      patients.map do |patient|
        latest_sync_log = grouped_sync_logs[patient.patient_uuid]&.first
        patient.sync_status(latest_sync_log)
      end
    end
  end

  TREATMENT_NUMBER_DIGITS = 8.freeze

  def formatted_treatment_number
    treatment_number_prefix + treatment_number.to_s
  end

  def treatment_number_prefix
    return "" unless treatment_number_needs_prefix?

    prefix = "2018-"
    prefix + "0" * [TREATMENT_NUMBER_DIGITS - treatment_number.to_s.length, 0].max
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
    patient_sync_status == :synced
  end

  def unsynced?
    patient_sync_status == :unsynced
  end

  def syncable?
    unsynced? || patient_sync_status == :updated
  end

  def editable?
    unsynced? || patient_sync_status == :sync_errored
  end

  def patient_sync_status
    sync_status(latest_patient_sync_log)
  end

  def medical_history_sync_status
    sync_status(latest_medical_history_sync_log)
  end

  private

  def treatment_number_needs_prefix?
    true if treatment_number.nil? || Integer(treatment_number) rescue false
  end

  def latest_patient_sync_log
    latest_sync_logs(patient_uuid, 'Patient').first
  end

  def latest_medical_history_sync_log
    latest_sync_logs(medical_history_uuid, 'MedicalHistory').first
  end
end
