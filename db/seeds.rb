# frozen_string_literal: true

require 'ffaker'
require 'factory_girl_rails'
require 'paper_trail'
require 'timecop'

include FactoryGirl::Syntax::Methods

staff = create :user, :staff, :fake_name
puts 'Login as staff with:'
puts " Email:    #{staff.email}"
puts ' Password: password'

50.times { create :user, :driver, :fake_name }

incident_drivers = User.drivers

dates = (4.months.ago.to_date..Date.yesterday).to_a
dates.shuffle.each.with_index do |day, i|
  driver = incident_drivers.sample
  # Every 20th incident shall be incomplete.
  incident_type = if (i % 20).zero? then :incomplete
                  else [nil, :collision, :passenger_incident].sample
                  end
  incident_attrs = { driver: driver }
  Timecop.freeze day + rand(24 * 60).minutes do
    PaperTrail.whodunnit = driver.id
    incident = if incident_type.present?
                 create :incident, incident_type, incident_attrs
               else create :incident, incident_attrs
               end
    # Every 8th-ish incident shall be unreviewed.
    unless incident_type == :incomplete || (i % 8).zero?
      create :staff_review, incident: incident, user: staff
    end
  end
end
