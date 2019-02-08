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
    @synced ||= patients.select(&:synced?).size
  end

  def unsynced
    @unsynced ||= patients.select(&:unsynced?).size
  end

  def errored
    @errored ||= patients.select(&:sync_error?).size
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
end
