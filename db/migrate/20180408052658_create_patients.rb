class CreatePatients < ActiveRecord::Migration[5.1]
  def change
    create_table :patients do |t|
      t.integer :card_id
      t.date :registered_on
      t.references :facility, foreign_key: true

      t.timestamps
    end
  end
end
