module SyncLoggable
  extend ActiveSupport::Concern

  def latest_sync_logs(simple_ids, simple_model)
    SyncLog.where(simple_id: simple_ids, simple_model: simple_model).order(synced_at: :desc)
  end

  def sync_status(sync_log)
    return :unsynced unless sync_log.present?
    if sync_log.synced_at < updated_at
      return :updated
    elsif sync_log.sync_errors.present?
      return :sync_errored
    else
      :synced
    end
  end
end
