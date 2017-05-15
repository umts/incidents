require 'ffaker'

User.create! name: 'David Faulkenberry',
             email: 'dave@example.com',
             password: 'password',
             password_confirmation: 'password',
             staff: true

50.times do
  name = FFaker::Name.name
  email = name.split.first + '@example.com'
  User.create! name: name,
               email: email,
               password: 'password',
               password_confirmation: 'password',
               staff: false
end

incident_drivers = User.drivers

(2.months.ago.to_date .. 2.months.since.to_date).each do |day|
  route = 30 + rand(20)
  Incident.create! driver: incident_drivers.sample,
                   occurred_at: day + rand(24 * 60).minutes,
                   shift: "#{route}-#{rand(5) + 1} #{%w[AM MID PM EVE].sample}",
                   route: route,
                   vehicle: (30 + rand(4)) * 100 + rand(20),
                   location: FFaker::Address.street_name,
                   action_before: %w[Turning Stopped Driving].sample,
                   action_during: %w[Turning Stopped Driving].sample,
                   weather_conditions: %w[Rainy Sunny Cloudy].sample,
                   light_conditions: %w[Dark Light Gray Fine].sample,
                   road_conditions: %w[Snow Icy Wet Dry Fine].sample,
                   camera_used: [true, false].sample,
                   injuries: [true, false].sample,
                   damage: [true, false].sample,
                   description: FFaker::Lorem.paragraphs.join(' ')
end
