# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name 'User'
    sequence :last_name
    sequence :hastus_id
    division { %w[SPFLD NOHO SMECH].sample }
    badge_number { rand(5000).to_s.rjust 4, '0' }

    before :create do |user|
      user.password = FFaker::Lorem.characters(12)
      user.password_confirmation = FFaker::Lorem.characters(12)
    end
  end

  trait :driver do
    supervisor false
    staff false
    before :create do |user|
      user.password = user.last_name
      user.password_confirmation = user.last_name
    end
  end

  trait :supervisor do
    supervisor true
    staff false
  end

  trait :staff do
    staff true
    supervisor { [true, false].sample }
  end

  trait :fake_name do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
  end
end
