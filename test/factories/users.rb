# frozen_string_literal: true

FactoryGirl.define do
  factory :user do
    first_name 'User'
    sequence :last_name
    sequence :hastus_id
    division { %w[SPFLD NOHO SMECH].sample }
    badge_number { rand(5000).to_s.rjust 4, '0' }
  end

  trait :driver do
    supervisor false
    staff false
  end

  trait :supervisor do
    supervisor true
    badge_number nil
  end

  trait :staff do
    staff true
    badge_number nil
  end

  trait :fake_name do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
  end
end
