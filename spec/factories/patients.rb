FactoryBot.define do
  factory :patient do
    association :author, factory: :user
    facility

    sequence(:treatment_number) { |n| "2018-%08i" % n }
    registered_on { 3.months.ago }
    name "Amir Singh"
    gender "Male"
    age 65
    house_number ""
    street_name ""
    area "Test Area"
    village "Test Village"
    district "Mansa"
    pincode "456123"
    phone "91234 56789"
    alternate_phone ""
    already_on_treatment false
    prior_heart_attack false
    heart_attack_in_last_3_years false
    prior_stroke false
    chronic_kidney_disease false
    medication1_name "Ibuprofen"
    medication1_dose "200mg"
    medication2_name ""
    medication2_dose ""
    medication3_name ""
    medication3_dose ""
    medication4_name ""
    medication4_dose ""
  end
end
