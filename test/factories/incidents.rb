# frozen_string_literal: true

FactoryGirl.define do
  factory :incident do
    association :driver, factory: :user
    motor_vehicle_collision false
    passenger_incident false
    completed true
    run                        { "Run #{rand 20}" }
    block                      { "Block #{rand 20}" }
    bus                        { 3_000 + 100 * rand(3) + rand(30) }
    occurred_at                { DateTime.now }
    passengers_onboard         { rand 40 }
    courtesy_cards_distributed { rand 5 }
    courtesy_cards_collected   { rand 5 }
    speed                      { rand 40 }
    location                   { FFaker::Address.street_name }
    town                       { %w[Amherst Northampton Springfield].sample }
    weather_conditions         { Incident::WEATHER_OPTIONS.sample }
    road_conditions            { Incident::ROAD_OPTIONS.sample }
    light_conditions           { Incident::LIGHT_OPTIONS.sample }
    description                { FFaker::BaconIpsum.paragraphs.join "\n" }
  end

  trait :motor_vehicle_collision do
    motor_vehicle_collision true
    # TODO
  end

  trait :passenger_incident do
    passenger_incident true
    # TODO
  end

  trait :incomplete do
    run                        nil
    block                      nil
    bus                        nil
    occurred_at                nil
    passengers_onboard         nil
    courtesy_cards_distributed nil
    courtesy_cards_collected   nil
    speed                      nil
    location                   nil
    town                       nil
    weather_conditions         nil
    road_conditions            nil
    light_conditions           nil
    description                nil
    completed false
  end

  trait :reviewed do
    after :create do |incident|
      create :staff_review, incident: incident
    end
  end
end
