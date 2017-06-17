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

supervisors = 10.times.map { |_| create :user, :supervisor, :fake_name }

drivers = 50.times.map { |_| create :user, :driver, :fake_name }

dates = (4.months.ago.to_date..Date.yesterday).to_a
dates.shuffle.each.with_index do |day, i|
  driver = drivers.sample
  supervisor = supervisors.sample
  # Every 20th incident shall be incomplete.
  incident_type = [nil, :collision, :passenger_incident].sample
  incident_type = :incomplete if (i % 9).zero?
  Timecop.freeze day + rand(24 * 60).minutes do
    PaperTrail.whodunnit = driver.id
    driver_report = if incident_type.present?
      create :incident_report, incident_type, user: driver
    else create :incident_report, user: driver
    end
    supervisor_report_attrs = driver_report.attributes.symbolize_keys
                                           .except(:id, :user_id)
                                           .merge(user: supervisor)
    supervisor_report = create :incident_report, supervisor_report_attrs
    incident = create :incident, driver_incident_report: driver_report,
                                 supervisor_incident_report: supervisor_report,
                                 supervisor_report: create(:supervisor_report, user: supervisor),
                                 completed: incident_type != :incomplete
    # TODO: create supervisor incident reports and supervisor reports
    # Every 8th-ish incident shall be unreviewed.
    unless incident_type == :incomplete || (i % 8).zero?
      create :staff_review, incident: incident, user: staff
    end
  end
end
