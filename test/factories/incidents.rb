# frozen_string_literal: true

FactoryGirl.define do
  factory :incident do
    association :driver_incident_report,
                factory: %i[incident_report driver_report]
    association :supervisor_incident_report,
                factory: %i[incident_report supervisor_report]
    association :supervisor_report
    occurred_at { DateTime.now.beginning_of_minute }

    after :create do |incident|
      if incident.completed? && incident.occurred_at < 2.weeks.ago
        incident.claim_number = "#{incident.occurred_at.year}#{rand 1000}"
      end
    end
  end
end
