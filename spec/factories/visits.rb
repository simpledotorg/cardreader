FactoryBot.define do
  factory :visit do
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
    referred_to_specialist false
    next_visit_on { measured_on + 1.month }
  end
end
