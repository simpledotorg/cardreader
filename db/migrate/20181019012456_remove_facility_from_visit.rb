class RemoveFacilityFromVisit < ActiveRecord::Migration[5.2]
  def change
    remove_index :visits, column: ["facilities_id"], name: "index_visits_on_facilities_id"
    remove_column :visits, :facilities_id, :bigint
  end
end
