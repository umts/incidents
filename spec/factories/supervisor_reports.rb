# frozen_string_literal: true

FactoryBot.define do
  factory :supervisor_report do
    pictures_saved                 { false }
    passenger_statement            { FFaker::Lorem.paragraphs(5).join "\n" }
    faxed                          { [nil, Time.zone.now].sample }
    test_not_conducted             { true }
    completed_drug_test            { false }
    completed_alcohol_test         { false }
    fta_threshold_not_met          { true }
    reason_threshold_not_met       { FFaker::Lorem.sentence }
    driver_discounted              { false }
    amplifying_comments            { FFaker::Lorem.paragraph if rand(20).zero? }

    trait :with_pictures do
      pictures_saved { true }
      saved_pictures { rand(50) + 1 }
    end

    trait :with_witness do
      before :create do |report|
        create :witness, supervisor_report: report
      end
    end

    trait :with_da_test do
      test_not_conducted             { false }
      fta_threshold_not_met          { false }
      driver_discounted              { false }
      reason_threshold_not_met       { nil }
      reason_driver_discounted       { nil }
      testing_facility               { SupervisorReport::TESTING_FACILITIES.sample }
      testing_facility_notified_at   { Time.zone.now - 6.minutes }
      employee_notified_of_test_at   { Time.zone.now - 5.minutes }
      employee_departed_to_test_at   { Time.zone.now - 4.minutes }
      employee_arrived_at_test_at    { Time.zone.now - 3.minutes }
      test_started_at                { Time.zone.now - 2.minutes }
      test_ended_at                  { Time.zone.now - 1.minute }
      employee_returned_at           { Time.zone.now }
    end

    trait :with_drug_test do
      with_da_test
      completed_drug_test { true }
    end

    trait :with_alcohol_test do
      with_da_test
      completed_alcohol_test { true }
    end

    trait :tested_post_accident do
      with_da_test
      reason_test_completed { 'Post-Accident' }

      before :create do |report|
        field = %w[
          test_due_to_bodily_injury
          test_due_to_disabling_damage
          test_due_to_fatality
        ].sample
        report.send field + '=', true
      end
    end

    trait :tested_rs do
      with_da_test
      reason_test_completed { 'Reasonable Suspicion' }
      observation_made_at   { Time.zone.now - 5.minutes }

      before :create do |report|
        reason = %w[appearance behavior speech odor].sample
        report.send "test_due_to_employee_#{reason}=", true
        report.send "employee_#{reason}=", FFaker::Lorem.sentence
      end
    end
  end
end
