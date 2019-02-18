class SyncReport < Struct.new(:sync_statuses)
  def synced
    sync_statuses.count(:synced)
  end

  def synced_percentage
    100.0 * synced / total_records
  end

  def unsynced
    sync_statuses.count(:unsynced)
  end

  def unsynced_percentage
    100.0 * unsynced / total_records
  end

  def errored
    sync_statuses.count(:sync_errored)
  end

  def sync_error_percentage
    100.0 * errored / total_records
  end

  private

  def total_records
    synced + unsynced + errored
  end
end
