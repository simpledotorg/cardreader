class RemoveOldSyncColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :patients, :synced_at, :datetime
    remove_column :patients, :last_sync_errors, :json

    remove_column :visits, :synced_at, :datetime
    remove_column :visits, :last_sync_errors, :json
  end
end
