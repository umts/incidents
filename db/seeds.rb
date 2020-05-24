# frozen_string_literal: true

require 'factory_bot_rails'
require 'ffaker'
require 'paper_trail'
require 'timecop'

module Seeds
  extend FactoryBot::Syntax::Methods

  divisions = %w[SPFLD NOHO SMECH].map { |n| create :division, name: n }

  staff = Array.new(5) do
    create :user,
           :staff,
           :fake_name,
           divisions: [divisions.sample]
  end

  supervisors = Array.new(10) do
    create :user,
           :supervisor,
           :fake_name,
           divisions: [divisions.sample]
  end

  drivers = Array.new(50) do
    create :user,
           :driver,
           :fake_name,
           divisions: [divisions.sample]
  end

  # Create a known test user for simplicity
  user = create :user,
                :staff,
                first_name: 'first',
                last_name: 'last',
                badge_number: 5000,
                divisions: [divisions.sample]
  user.update password: 'password', password_confirmation: 'password'

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
    claim_date = 2.weeks.ago
    Timecop.freeze day + rand(24 * 60).minutes do
      PaperTrail.request.whodunnit = driver.id
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
      if incident_type == :incomplete
        incident = build :incident, incident_attrs
        # Validations don't pass for incomplete incidents. They do in real life,
        # but they don't because we create objects in reverse order here.
        incident.save! validate: false
      else incident = create :incident, :completed, incident_attrs
      end
      if Time.zone.now < claim_date
        number = if rand(5).zero?
                   Incident.pluck(:claim_number).compact.sample
                 else
                   Time.zone.now.year.to_s + rand(10_000).to_s.rjust(4, '0')
                 end
        incident.update claim_number: number
      end
      # Every 8th-ish incident shall be reviewed.
      if (i % 8).zero? && incident_type != :incomplete
        create :staff_review, incident: incident, user: staff.sample
      end
    end
  end
end
