# frozen_string_literal: true

FactoryBot.define do
  factory :supervisor_report do
    pictures_saved { false }
    passenger_statement { FFaker::Lorem.paragraphs(5).join "\n" }
    faxed { [nil, Time.zone.now].sample }
    testing_facility { SupervisorReport::TESTING_FACILITIES.sample }
    testing_facility_notified_at { 6.minutes.ago }
    employee_notified_of_test_at { 5.minutes.ago }
    employee_departed_to_test_at { 4.minutes.ago }
    employee_arrived_at_test_at { 3.minutes.ago }
    test_started_at { 2.minutes.ago }
    test_ended_at { 1.minute.ago }
    employee_representative_arrived_at { Time.zone.now }

    before :create do |report|
      report.saved_pictures = rand 50 if report.pictures_saved?
    end

    after :build do |report|
      report.amplifying_comments = FFaker::Lorem.paragraph if report.test_status?
    end

    trait :with_witness do
      before :create do |report|
        create :witness, supervisor_report: report
      end
    end

    trait :with_pictures do
      pictures_saved     { true }
      saved_pictures     { rand(9_999) }
    end

    trait :with_test_status do
      test_status { SupervisorReport::REASONS_FOR_TEST.keys.sample }
    end
  end
end
