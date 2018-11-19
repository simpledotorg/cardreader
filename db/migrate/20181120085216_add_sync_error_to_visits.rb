class AddSyncErrorToVisits < ActiveRecord::Migration[5.2]
  def change
    add_column :visits, :last_sync_error, :text, null: true
  end
end
