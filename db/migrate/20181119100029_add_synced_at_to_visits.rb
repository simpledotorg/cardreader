class AddSyncedAtToVisits < ActiveRecord::Migration[5.2]
  def change
    add_column :visits, :synced_at, :datetime, null: true
  end
end
