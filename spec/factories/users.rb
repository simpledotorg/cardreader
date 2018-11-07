FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.com" }
    password "helloworld"
    role :operator

    trait(:admin) { role :admin }
    trait(:operator) { role :operator }
  end
end
