class AddSyncErrorToPatients < ActiveRecord::Migration[5.2]
  def change
    add_column :patients, :last_sync_error, :text, null: true
  end
end
