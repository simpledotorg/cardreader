class Visit < ApplicationRecord
  belongs_to :patient, inverse_of: :visits

  delegate :facility, to: :patient

  TIME_WITHOUT_TIMEZONE_FORMAT = '%FT%T.%3NZ'.freeze

  validates :measured_on, presence: true
  validates_date :measured_on
  validates_date :next_visit_on, allow_blank: true,
                 after: :measured_on, after_message: "must be later than the date attended"

  def measured_on_without_timestamp
    self.measured_on.strftime(TIME_WITHOUT_TIMEZONE_FORMAT)
  end

  def synced?
    blood_pressure_synced? && appointment_synced?
  end

  private

  def sync_status(sync_log)
    return :unsynced unless sync_log.present?
    if sync_log.sync_errors.present?
      return :sync_errored
    elsif sync_log.synced_at > updated_at
      return :synced
    end
    :unsynced
  end

  def blood_pressure_synced?
    sync_status(latest_blood_pressure_sync_log) == :synced
  end

  def appointment_synced?
    sync_status(latest_appointment_sync_log) == :synced
  end

  def latest_blood_pressure_sync_log
    SyncLog.where(simple_id: blood_pressure_uuid, simple_model: 'BloodPressure').order(synced_at: :desc).first
  end

  def latest_appointment_sync_log
    SyncLog.where(simple_id: appointment_uuid, simple_model: 'Appointment').order(synced_at: :desc).first
  end
end