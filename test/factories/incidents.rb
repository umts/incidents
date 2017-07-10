# frozen_string_literal: true

FactoryGirl.define do
  factory :incident do
    association :driver_incident_report,
                factory: %i[incident_report driver_report]
    association :supervisor_incident_report,
                factory: %i[incident_report supervisor_report]
    association :supervisor_report
    occurred_at { DateTime.now.beginning_of_minute }
  end
end
