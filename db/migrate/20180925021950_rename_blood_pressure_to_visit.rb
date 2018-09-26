class RenameBloodPressureToVisit < ActiveRecord::Migration[5.2]
  def change
    rename_table :blood_pressures, :visits
  end
end
