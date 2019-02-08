module SyncReportable
  extend ActiveSupport::Concern

  def last_synced_at
    @time ||= patients
                .joins("INNER JOIN sync_logs ON sync_logs.simple_id = patients.patient_uuid")
                .where(sync_logs: { sync_errors: nil })
                .maximum('sync_logs.synced_at')

    @time&.to_formatted_s(:long)
  end

  def synced
    patient_sync_statuses.count(:synced)
  end

  def unsynced
    patient_sync_statuses.count(:unsynced)
  end

  def errored
    patient_sync_statuses.count(:sync_errored)
  end

  def synced_percentage
    100.0 * synced / total
  end

  def unsynced_percentage
    100.0 * unsynced / total
  end

  def sync_error_percentage
    100.0 * errored / total
  end

  def total
    synced + unsynced + errored
  end

  def highest_treatment_number
    'N/A'
  end

  private

  def patient_sync_statuses
    @patient_sync_statuses ||= patients.map(&:patient_sync_status)
  end
end
