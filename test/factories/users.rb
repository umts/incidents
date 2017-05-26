# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "User#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    # Please change the seed file if you change this password.
    password 'password'
    password_confirmation 'password'
    staff false
  end

  trait :driver do
    staff false
    badge_number { rand(5000).to_s.rjust 4, '0' }
  end

  trait :staff do
    staff true
  end

  trait :fake_name do
    name { FFaker::Name.name }
  end
end
