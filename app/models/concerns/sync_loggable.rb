module SyncLoggable
  extend ActiveSupport::Concern

  def latest_sync_log(simple_id, simple_model)
    SyncLog.where(simple_id: simple_id, simple_model: simple_model).order(synced_at: :desc).first
  end

  def sync_status(sync_log)
    return :unsynced if sync_log.blank?

    if sync_log.synced_at < updated_at
      :updated
    elsif sync_log.sync_errors.present?
      :sync_errored
    else
      :synced
    end
  end
end
