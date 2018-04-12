FactoryBot.define do
  factory :patient do
    facility

    sequence(:treatment_number) { |n| "2018-%08i" % n }
    registered_on { 3.months.ago }
  end
end
