FactoryBot.define do
  factory :user do
    name                  { Faker::Name.name }
    email                 { Faker::Internet.unique.email }
    password              { "password123" }
    password_confirmation { "password123" }
    confirmed_at          { Time.current }

    trait :unconfirmed do
      confirmed_at { nil }
      after(:build) { |user| user.skip_confirmation_notification! }
    end

    trait :locked do
      locked_at       { Time.current }
      failed_attempts { 5 }
    end
  end
end
