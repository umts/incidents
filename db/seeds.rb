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
  incident_type = [nil, :incomplete, :collision, :passenger_incident].sample
  Timecop.freeze day + rand(24 * 60).minutes do
    PaperTrail.whodunnit = driver.id
    report = if incident_type.present?
      create :incident_report, incident_type, user: driver
    else create :incident_report, user: driver
    end
    incident = create :incident, driver_incident_report: report
    # TODO: create supervisor incident reports and supervisor reports
    # Every 8th-ish incident shall be unreviewed.
    unless incident_type == :incomplete || (i % 8).zero?
      create :staff_review, incident: incident, user: staff
    end
  end
end
