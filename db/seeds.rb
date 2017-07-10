# frozen_string_literal: true

require 'ffaker'
require 'factory_girl_rails'
require 'paper_trail'
require 'timecop'

include FactoryGirl::Syntax::Methods

staff = create :user, :staff, :fake_name

supervisors = Array.new(10) { create :user, :supervisor, :fake_name }

drivers = Array.new(50) { create :user, :driver, :fake_name }

codes = {
  collision: create(:reason_code, description: 'Collision'),
  passenger_incident: create(:reason_code, description: 'Passenger Incident'),
  nil => create(:reason_code, description: 'Other')
}

dates = (4.months.ago.to_date..Date.yesterday).to_a
dates.shuffle.each.with_index do |day, i|
  driver = drivers.sample
  # Every 20th incident shall be incomplete.
  incident_type = [nil, :collision, :passenger_incident].sample
  incident_type = :incomplete if (i % 9).zero?
  Timecop.freeze day + rand(24 * 60).minutes do
    PaperTrail.whodunnit = driver.id
    driver_report = if incident_type.present?
                      create :incident_report, incident_type, user: driver
                    else create :incident_report, user: driver
                    end
    incident_attrs = { driver_incident_report: driver_report,
                       completed: incident_type != :incomplete,
                       reason_code: codes[incident_type] }
    # Only every other incident should require supervisor response.
    if i.even?
      supervisor = supervisors.sample
      supervisor_report_attrs = driver_report.attributes.symbolize_keys
                                             .except(:id, :user_id)
                                             .merge(user: supervisor)
      supervisor_report = create :incident_report, supervisor_report_attrs
      incident_attrs[:supervisor_incident_report] = supervisor_report
      incident_attrs[:supervisor_report] = create :supervisor_report
    else
      incident_attrs[:supervisor_incident_report] = nil
      incident_attrs[:supervisor_report] = nil
    end
    incident = create :incident, incident_attrs
    # Every 8th-ish incident shall be reviewed.
    if (i % 8).zero? && incident_type != :incomplete
      create :staff_review, incident: incident, user: staff
    end
  end
end
