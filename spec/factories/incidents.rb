# frozen_string_literal: true

FactoryBot.define do
  factory :incident do
    occurred_at { DateTime.now.beginning_of_minute }
    association :driver_incident_report,
                factory: %i[incident_report driver_report]

    association :supervisor_incident_report,
                factory: %i[incident_report supervisor_report]

    association :supervisor_report
    completed { false }

    trait :completed do
      completed { true }
      association :reason_code
      association :supplementary_reason_code
      root_cause_analysis { FFaker::Lorem.paragraph }
      latitude { "42.#{rand(100_000).to_s.rjust 5, '0'}" }
      longitude { "-72.#{rand(100_000).to_s.rjust 5, '0'}" }
    end

    trait :unclaimed do
      supervisor_incident_report { nil }
      supervisor_report { nil }
    end
  end
end
