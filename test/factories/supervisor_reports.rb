# frozen_string_literal: true

FactoryGirl.define do
  factory :supervisor_report do
    association :user
    # TODO: make look more realistic
  end
end
