# frozen_string_literal: true

FactoryGirl.define do
  factory :incident do
    association :driver, factory: :user
    occurred_at DateTime.now
    shift              '30-3 AM'
    route              '30'
    vehicle            '3215'
    location           'Main St.'
    action_before      'Turning'
    action_during      'Stopped'
    weather_conditions 'Fine'
    light_conditions   'Fine'
    road_conditions    'Fine'
    description        'Collided mirrors.'
    completed true
  end

  trait :incomplete do
    shift              nil
    route              nil
    vehicle            nil
    location           nil
    action_before      nil
    action_during      nil
    weather_conditions nil
    light_conditions   nil
    road_conditions    nil
    description        nil
    completed false
  end

  trait :reviewed do
    after :create do |incident|
      create :staff_review, incident: incident
    end
  end
end
