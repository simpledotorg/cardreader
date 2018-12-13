FactoryBot.define do
  factory :visit do
    association :author, factory: :user
    patient

    systolic { rand(100.160) }
    diastolic { rand(60..120) }
    measured_on { Faker::Date.between(3.months.ago, Date.today) }
    blood_sugar ""
    amlodipine "10mg"
    telmisartan "40mg"
    enalpril ""
    chlorthalidone ""
    aspirin ""
    statin ""
    beta_blocker ""
    losartan ""
    medication1_name ""
    medication1_dose ""
    medication2_name ""
    medication2_dose ""
    medication3_name ""
    medication3_dose ""
    referred_to_specialist false
    next_visit_on { measured_on + 1.month }
  end
end
