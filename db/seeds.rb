# frozen_string_literal: true

require 'ffaker'
require 'factory_girl_rails'

include FactoryGirl::Syntax::Methods

staff = create :user, :staff, :fake_name
puts 'Login as staff with:'
puts " Email:    #{staff.email}"
puts ' Password: password'

50.times { create :user, :driver, :fake_name }

incident_drivers = User.drivers

dates = (2.months.ago.to_date..2.months.since.to_date).to_a
dates.shuffle.each.with_index do |day, i|
  # Every 20th incident shall be incomplete.
  incident_type = if (i % 20).zero? then :incomplete
                  else [nil, :collision, :passenger_incident].sample
                  end
  incident_attrs = { driver: incident_drivers.sample,
                     occurred_at: day + rand(24 * 60).minutes }
  incident = if incident_type.present?
               create :incident, incident_type, incident_attrs
             else create :incident, incident_attrs
             end
  # Every 8th incident shall be unreviewed.
  create :staff_review, incident: incident, user: staff unless (i % 8).zero?
end
