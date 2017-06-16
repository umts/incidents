# frozen_string_literal: true

FactoryGirl.define do
  factory :incident do
    association :driver_incident_report, factory: :incident_report
    association :supervisor_incident_report, factory: :incident_report
    association :supervisor_report
  end
end
