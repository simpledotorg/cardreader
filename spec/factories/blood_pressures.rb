FactoryBot.define do
  factory :blood_pressure do
    patient

    systolic { rand(100.160) }
    diastolic { rand(60..120) }
    measured_on { Faker::Date.between(3.months.ago, Date.today) }
  end
end
