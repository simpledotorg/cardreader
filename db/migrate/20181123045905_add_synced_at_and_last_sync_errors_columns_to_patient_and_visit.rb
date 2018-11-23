class AddSyncedAtAndLastSyncErrorsColumnsToPatientAndVisit < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :synced_at, :timestamp, null: true
    add_column :patients, :last_sync_errors, :json, null: true

    add_column :visits, :synced_at, :timestamp, null: true
    add_column :visits, :last_sync_errors, :json, null: true
  end
end
