# frozen_string_literal: true

FactoryGirl.define do
  factory :reason_code do
    sequence(:identifier) { |n| "C-#{n}" }
    sequence(:description) { |n| "Code #{n}" }
  end
end
