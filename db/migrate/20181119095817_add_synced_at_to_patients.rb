class AddSyncedAtToPatients < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :synced_at, :datetime, null: true
  end
end
