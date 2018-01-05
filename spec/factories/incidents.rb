# frozen_string_literal: true

FactoryBot.define do
  factory :incident do
    association :driver_incident_report,
                factory: %i[incident_report driver_report]
    association :supervisor_incident_report,
                factory: %i[incident_report supervisor_report]
    association :supervisor_report

    trait :completed do
      completed true
      association :reason_code
    end

    trait :unclaimed do
      supervisor_incident_report nil
      supervisor_report nil
    end
  end
end
