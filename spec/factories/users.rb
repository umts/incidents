# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name   { 'User' }
    sequence     :last_name
    divisions    { [create(:division)] }
    badge_number { (('0000'..'4999').to_a - User.pluck(:badge_number)).sample }

    after :create do |user|
      user.update password: 'Password1', password_confirmation: 'Password1'
    end

    trait :driver do
      supervisor { false }
      staff      { false }
    end

    trait :supervisor do
      supervisor { true }
      staff      { false }
    end

    trait :staff do
      staff      { true }
      supervisor { false }
    end

    trait :fake_name do
      first_name { FFaker::Name.first_name }
      last_name { FFaker::Name.last_name }
    end

    trait :default_password do
      after :create do |user|
        user.set_default_password
        user.save
      end
    end
  end
end
