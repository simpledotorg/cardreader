module SyncReportable
  extend ActiveSupport::Concern

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
    denominator = (synced + unsynced + errored)
    100.0 * synced / denominator
  end

  def unsynced_percentage
    denominator = (synced + unsynced + errored)
    100.0 * unsynced / denominator
  end
end
