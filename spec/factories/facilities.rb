FactoryBot.define do
  factory :facility do
    association :author, factory: :user
    district

    sequence(:name) { |n| "Facility #{n}" }
  end
end
