class AddOtherMedsToVisit < ActiveRecord::Migration[5.2]
  def change
    change_table :visits do |t|
      t.column :losartan, :string
      t.column :medication1_name, :string
      t.column :medication1_dose, :string
      t.column :medication2_name, :string
      t.column :medication2_dose, :string
      t.column :medication3_name, :string
      t.column :medication3_dose, :string
    end
  end
end
