module SyncLoggable
  extend ActiveSupport::Concern

  def latest_sync_log(simple_id, simple_model)
    SyncLog.where(simple_id: simple_id, simple_model: simple_model).order(synced_at: :desc).first
  end

  def sync_status(sync_log)
    return :unsynced unless sync_log.present?
    if sync_log.sync_errors.present?
      return :sync_errored
    elsif sync_log.synced_at < updated_at
      return :updated
    else
      :synced
    end
  end
end
