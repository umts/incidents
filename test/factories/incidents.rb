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

  trait :collision do
    motor_vehicle_collision true
    other_vehicle_owned_by_other_driver true # so that we don't need all those fields
    police_on_scene false # so that we don't need those fields
    other_vehicle_plate                     { FFaker::String.from_regexp(/\A\d[A-Z][A-Z][A-Z]\d{2}\Z/) }
    other_vehicle_state                     { %w[MA RI CT NY].sample }
    other_vehicle_make                      { FFaker::Vehicle.make }
    other_vehicle_model                     { FFaker::Vehicle.model }
    other_vehicle_year                      { 1_997 + rand(20) }
    other_vehicle_color                     { FFaker::Vehicle.base_color }
    other_vehicle_passengers                { 1 + rand(3) }
    direction                               { Incident::DIRECTION_OPTIONS.sample }
    other_vehicle_direction                 { Incident::DIRECTION_OPTIONS.sample }
    other_driver_name                       { FFaker::Name.name }
    other_driver_license_number             { "S" + rand(99_999_999).to_s.rjust(8, '0') }
    other_driver_license_state              { %w[MA RI CT NY].sample }
    other_vehicle_driver_address            { FFaker::Address.street_address }
    other_vehicle_driver_address_town       { FFaker::Address.city }
    other_vehicle_driver_address_state      { %w[MA RI CT NY].sample }
    other_vehicle_driver_address_zip        { FFaker::AddressUS.zip_code }
    other_vehicle_driver_home_phone         { FFaker::PhoneNumber.short_phone_number }
    damage_to_bus_point_of_impact           { 'Not sure what this should look like' }
    damage_to_other_vehicle_point_of_impact { 'Not sure what this should look like' }
    insurance_carrier                       { %w[Geico Progressive AAA].sample }
    insurance_policy_number                 { rand(999_999_999) }
    insurance_effective_date                { Date.today - rand(365).days }
  end

  trait :other_vehicle_not_driven_by_owner do
    other_vehicle_owned_by_other_driver false
    other_vehicle_owner_name               { FFaker::Name.name }
    other_vehicle_owner_address            { FFaker::Address.street_address }
    other_vehicle_owner_address_town       { FFaker::Address.city }
    other_vehicle_owner_address_state      { %w[MA RI CT NY].sample }
    other_vehicle_owner_address_zip        { FFaker::AddressUS.zip_code }
    other_vehicle_owner_home_phone         { FFaker::PhoneNumber.short_phone_number }
  end

  trait :police_on_scene do
    police_on_scene true
    police_badge_number { rand(9_999) }
    police_town_or_state { %w[Amherst Northampton Springfield State].sample }
    police_case_assigned { rand(99_999_999) }
  end

  trait :passenger_incident do
    passenger_incident true
    bus_up_to_curb true # so that we don't need reason_not_up_to_curb
    occurred_front_door      { FFaker::Boolean.random }
    occurred_rear_door       { FFaker::Boolean.random }
    occurred_front_steps     { FFaker::Boolean.random }
    occurred_rear_steps      { FFaker::Boolean.random }
    occurred_sudden_stop     { FFaker::Boolean.random }
    occurred_before_boarding { FFaker::Boolean.random }
    occurred_while_boarding  { FFaker::Boolean.random }
    occurred_after_boarding  { FFaker::Boolean.random }
    occurred_while_exiting   { FFaker::Boolean.random }
    occurred_after_exiting   { FFaker::Boolean.random }
    motion_of_bus            { Incident::BUS_MOTION_OPTIONS.sample }
    condition_of_steps       { Incident::STEP_CONDITION_OPTIONS.sample }
    bus_kneeled              { FFaker::Boolean.random }
  end

  trait :not_up_to_curb do
    motion_of_bus 'Stopped'
    bus_up_to_curb false
    reason_not_up_to_curb     { FFaker::BaconIpsum.sentence }
    vehicle_in_bus_stop_plate { FFaker::String.from_regexp(/\A\d[A-Z][A-Z][A-Z]\d{2}\Z/) }
  end

  trait :injured_passengers do
    injured_passengers do
      3.times.map do
        {
          name:    FFaker::Name.name,
          address: FFaker::Address.street_address,
          town:    FFaker::Address.city,
          state:   %w[MA RI CT NY].sample,
          zip:     FFaker::AddressUS.zip_code,
          phone:   FFaker::PhoneNumber.short_phone_number
        }
      end
    end
  end

  trait :incomplete do
    run                        nil
    block                      nil
    bus                        nil
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
