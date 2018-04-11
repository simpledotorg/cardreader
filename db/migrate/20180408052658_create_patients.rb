class CreatePatients < ActiveRecord::Migration[5.1]
  def change
    create_table :patients do |t|
      t.string :treatment_number
      t.date :registered_on
      t.references :facility, foreign_key: true

      t.timestamps
    end
  end
end
