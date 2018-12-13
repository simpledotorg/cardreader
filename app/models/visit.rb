class Visit < ApplicationRecord
  include SyncLoggable

  belongs_to :author, class_name: "User", foreign_key: "author_id"
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

  def blood_pressure_synced?
    blood_pressure_sync_status == :synced
  end

  def appointment_synced?
    appointment_sync_status == :synced
  end

  def blood_pressure_sync_status
    sync_status(latest_blood_pressure_sync_log)
  end

  def appointment_sync_status
    sync_status(latest_appointment_sync_log)
  end

  private

  def latest_blood_pressure_sync_log
    latest_sync_log(blood_pressure_uuid, 'BloodPressure')
  end

  def latest_appointment_sync_log
    latest_sync_log(appointment_uuid, 'Appointment')
  end
end
