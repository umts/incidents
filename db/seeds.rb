require 'ffaker'

User.create! name: 'David Faulkenberry',
             email: 'dave@example.com',
             password: 'password',
             password_confirmation: 'password',
             staff: true

50.times do
  name = FFaker::Name.name
  first_name = name.split.first
  users_with_first_name = User.select{ |u| u.name.start_with? first_name }
  email = if users_with_first_name.present?
            name.split.first.downcase +
              users_with_first_name.count.to_s +
              '@example.com'
          else name.split.first.downcase + '@example.com'
          end
  User.create! name: name,
               email: email,
               password: 'password',
               password_confirmation: 'password',
               staff: false
end

incident_drivers = User.drivers

(2.months.ago.to_date .. 2.months.since.to_date).to_a.shuffle.each.with_index do |day, i|
  route = 30 + rand(20)
  if i % 20 == 0
    Incident.create! driver: incident_drivers.sample,
                     completed: false
  else
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
                     description: FFaker::BaconIpsum.paragraphs.join("\n"),
                     completed: true
  end
  # Every eighth incident shall be not reviewed.
  unless i % 8 == 0
    StaffReview.create! incident: Incident.last, user: User.first,
      text: FFaker::BaconIpsum.paragraph
  end
end
