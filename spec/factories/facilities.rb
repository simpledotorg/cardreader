FactoryBot.define do
  factory :facility do
    district
    user

    sequence(:name) { |n| "Facility #{n}" }
  end
end
