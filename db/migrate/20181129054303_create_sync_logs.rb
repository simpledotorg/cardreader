class CreateSyncLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :sync_logs do |t|
      t.string :simple_model
      t.uuid :simple_id
      t.timestamp :synced_at, null: false
      t.json :sync_errors
      t.timestamps
    end

    add_index :sync_logs, [:simple_model, :simple_id]
  end
end
