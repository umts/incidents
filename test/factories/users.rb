FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "User#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
    staff false
  end

  trait :staff do
    staff true
  end
end
