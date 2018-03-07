# frozen_string_literal: true

FactoryBot.define do
  factory :injured_passenger do
    incident_report
    name { FFaker::Name.name }
    address do
      [FFaker::AddressUS.street_address,
       %w[Amherst Northampton Springfield].sample].join(', ')
    end
    nature_of_injury { FFaker::BaconIpsum.sentence }
    home_phone { FFaker::PhoneNumber.short_phone_number if rand(2).zero? }
    cell_phone { FFaker::PhoneNumber.short_phone_number }
    work_phone { FFaker::PhoneNumber.short_phone_number if rand(4).zero? }
  end
end
