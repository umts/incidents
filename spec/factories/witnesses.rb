FactoryBot.define do
  factory :witness do
    supervisor_report
    name { FFaker::Name.name }

    address do
      [FFaker::AddressUS.street_address,
       %w[Amherst Northampton Springfield].sample].join(', ')
    end

    onboard_bus { [true, false].sample }
    home_phone  { FFaker::PhoneNumber.short_phone_number if rand(2).zero? }
    cell_phone  { FFaker::PhoneNumber.short_phone_number }
    work_phone  { FFaker::PhoneNumber.short_phone_number if rand(4).zero? }
  end
end
