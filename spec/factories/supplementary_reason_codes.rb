# frozen_string_literal: true

FactoryBot.define do
  factory :supplementary_reason_code do
    sequence(:identifier) { |n| "D-#{n}" }
    sequence(:description) { |n| "Scenario #{n}" }
  end
end
