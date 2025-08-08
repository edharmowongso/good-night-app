FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:username) { |n| "user#{n}" }
    user_status { :active }

    trait :inactive do
      user_status { :inactive }
    end
  end
end
