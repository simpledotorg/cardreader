class CreateBloodPressures < ActiveRecord::Migration[5.1]
  def change
    create_table :blood_pressures do |t|
      t.references :patient, foreign_key: true
      t.integer :systolic
      t.integer :diastolic
      t.date :measured_on

      t.timestamps
    end
  end
end
