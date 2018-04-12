FactoryBot.define do
  factory :district do
    sequence(:name) { |n| "District #{n}" }
  end
end
