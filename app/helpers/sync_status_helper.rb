module SyncStatusHelper
  CSS_CLASSES = {
    unsynced: 'badge-dark',
    sync_errored: 'badge-danger',
    updated: 'badge-warning',
    synced: 'badge-success'
  }.freeze

  def sync_status_class(sync_status)
    CSS_CLASSES[sync_status]
  end
end
