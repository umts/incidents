# frozen_string_literal: true

FactoryBot.define do
  factory :division do
    sequence(:name) { |n| "Division #{n}" }
  end
end
