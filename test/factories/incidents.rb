# frozen_string_literal: true

FactoryGirl.define do
  factory :incident do
    association :driver_incident_report, factory: :incident_report
    association :supervisor_incident_report, factory: :incident_report
    association :supervisor_report
    occurred_at { DateTime.now.beginning_of_minute }
  end
end
