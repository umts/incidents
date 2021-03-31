# frozen_string_literal: true

FactoryBot.define do
  factory :incident_report do
    association :user
    motor_vehicle_collision    { false }
    passenger_incident         { false }
    run                        { rand 1_000 }
    route                      { rand 1_000 }
    block                      { "Block #{rand 20}" }
    bus                        { 3_000 + 100 * rand(3) + rand(30) }
    direction                  { IncidentReport::DIRECTIONS.keys.sample }
    passengers_onboard         { rand 40 }
    courtesy_cards_distributed { rand 5 }
    courtesy_cards_collected   { rand 5 }
    speed                      { rand 40 }
    location                   { FFaker::Address.street_name }
    town                       { %w[Amherst Northampton Springfield].sample }
    zip                        { '01' + rand(1_000).to_s.rjust(3, '0') }
    weather_conditions         { IncidentReport::WEATHER_OPTIONS.sample }
    road_conditions            { IncidentReport::ROAD_OPTIONS.sample }
    light_conditions           { IncidentReport::LIGHT_OPTIONS.sample }
    description                { FFaker::Lorem.paragraphs(5).join "\n" }
    occurred_at { DateTime.now.beginning_of_minute }

    trait :driver_report do
      association :user, factory: %i[user driver]
    end

    trait :supervisor_report do
      association :user, factory: %i[user supervisor]
    end

    trait :collision do
      motor_vehicle_collision                 { true }

      # so that we don't need all those fields
      other_vehicle_owned_by_other_driver     { true }
      # so that we don't need those fields
      police_on_scene                         { false }

      other_vehicle_plate                     { FFaker::String.from_regexp(/\A\d[A-Z][A-Z][A-Z]\d{2}\Z/) }
      other_vehicle_state                     { %w[MA RI CT NY].sample }
      other_vehicle_make                      { FFaker::Vehicle.make }
      other_vehicle_model                     { FFaker::Vehicle.model }
      other_vehicle_year                      { rand(1997..2016) }
      other_vehicle_color                     { %w[Red White Blue].sample }
      other_vehicle_passengers                { rand(1..3) }
      other_vehicle_direction                 { %w[North South East West].sample }
      other_driver_name                       { FFaker::Name.name }
      other_driver_license_number             { 'S' + rand(99_999_999).to_s.rjust(8, '0') }
      other_driver_license_state              { %w[MA RI CT NY].sample }
      other_vehicle_driver_address            { FFaker::Address.street_address }
      other_vehicle_driver_address_town       { FFaker::Address.city }
      other_vehicle_driver_address_state      { %w[MA RI CT NY].sample }
      other_vehicle_driver_address_zip        { FFaker::AddressUS.zip_code }
      other_vehicle_driver_home_phone         { FFaker::PhoneNumber.short_phone_number }
      point_of_impact                         { IncidentReport::IMPACT_LOCATION_OPTIONS.sample }
      damage_to_bus_point_of_impact           { %w[Scratches Dents Major\ dents].sample }
      damage_to_other_vehicle_point_of_impact { %w[Scratches Dents Major\ dents].sample }
      insurance_carrier                       { %w[Geico Progressive AAA].sample }
      insurance_policy_number                 { rand(999_999_999) }
      insurance_effective_date                { Date.today - rand(365).days }
    end

    trait :other_vehicle_not_driven_by_owner do
      other_vehicle_owned_by_other_driver    { false }
      other_vehicle_owner_name               { FFaker::Name.name }
      other_vehicle_owner_address            { FFaker::Address.street_address }
      other_vehicle_owner_address_town       { FFaker::Address.city }
      other_vehicle_owner_address_state      { %w[MA RI CT NY].sample }
      other_vehicle_owner_address_zip        { FFaker::AddressUS.zip_code }
      other_vehicle_owner_home_phone         { FFaker::PhoneNumber.short_phone_number }
    end

    trait :police_on_scene do
      police_on_scene      { true }
      police_badge_number  { rand(9_999) }
      police_town_or_state { %w[Amherst Northampton Springfield State].sample }
      police_case_assigned { rand(99_999_999) }
    end

    trait :passenger_incident do
      passenger_incident       { true }

      # so that we don't need reason_not_up_to_curb
      bus_up_to_curb           { true }

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
      motion_of_bus            { IncidentReport::BUS_MOTION_OPTIONS.sample }
      condition_of_steps       { IncidentReport::STEP_CONDITION_OPTIONS.sample }
      bus_kneeled              { FFaker::Boolean.random }
    end

    trait :with_injured_passenger do
      passenger_incident

      before :create do |report|
        create :injured_passenger, incident_report: report
      end
    end

    trait :not_up_to_curb do
      motion_of_bus             { 'Stopped' }
      bus_up_to_curb            { false }
      reason_not_up_to_curb     { FFaker::Lorem.sentence }
      vehicle_in_bus_stop_plate { FFaker::String.from_regexp(/\A\d[A-Z][A-Z][A-Z]\d{2}\Z/) }
    end

    trait :incomplete do
      run                        { nil }
      block                      { nil }
      bus                        { nil }
      passengers_onboard         { nil }
      courtesy_cards_distributed { nil }
      courtesy_cards_collected   { nil }
      speed                      { nil }
      location                   { nil }
      town                       { nil }
      weather_conditions         { nil }
      road_conditions            { nil }
      light_conditions           { nil }
      description                { nil }
    end

    trait :reviewed do
      after :create do |incident|
        create :staff_review, incident: incident
      end
    end

    trait :with_incident do
      after :create do |report|
        create :incident, driver_incident_report: report
      end
    end
  end
end
