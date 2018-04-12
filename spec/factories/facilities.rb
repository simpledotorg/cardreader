FactoryBot.define do
  factory :facility do
    district

    sequence(:name) { |n| "Facility #{n}" }
  end
end
