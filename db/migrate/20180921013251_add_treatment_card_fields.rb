class AddTreatmentCardFields < ActiveRecord::Migration[5.1]
  def change
    change_table :patients do |t|
      t.column :alternate_id_number, :string
      t.column :name, :string
      t.column :gender, :string
      t.column :age, :integer
      t.column :house_number, :string
      t.column :street_number, :string
      t.column :area, :string
      t.column :village, :string
      t.column :district, :string
      t.column :pincode, :string
      t.column :phone, :string
      t.column :alternate_phone, :string
      t.column :already_on_treatment, :boolean
      t.column :prior_heart_attack, :boolean
      t.column :heard_attack_in_last_3_years, :boolean
      t.column :prior_stroke, :boolean
      t.column :chronic_kidney_disease, :boolean
      t.column :medication1_name, :string
      t.column :medication1_dose, :string
      t.column :medication2_name, :string
      t.column :medication2_dose, :string
      t.column :medication3_name, :string
      t.column :medication3_dose, :string
      t.column :medication4_name, :string
      t.column :medication4_dose, :string
    end

    change_table :blood_pressures do |t|
      t.column :blood_sugar, :string
      t.column :amlodipine, :string
      t.column :telmisartan, :string
      t.column :enalpril, :string
      t.column :chlorthalidone, :string
      t.column :aspirin, :string
      t.column :statin, :string
      t.column :beta_blocker, :string
      t.column :referred_to_specialist, :boolean
      t.column :next_visit_on, :date
    end
  end
end
