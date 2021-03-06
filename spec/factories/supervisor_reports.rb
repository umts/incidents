# frozen_string_literal: true

FactoryBot.define do
  factory :supervisor_report do
    pictures_saved { false }
    passenger_statement { FFaker::Lorem.paragraphs(5).join "\n" }
    faxed { [nil, Time.zone.now].sample }
    testing_facility { SupervisorReport::TESTING_FACILITIES.sample }
    testing_facility_notified_at { Time.zone.now - 6.minutes }
    employee_notified_of_test_at { Time.zone.now - 5.minutes }
    employee_departed_to_test_at { Time.zone.now - 4.minutes }
    employee_arrived_at_test_at { Time.zone.now - 3.minutes }
    test_started_at { Time.zone.now - 2.minutes }
    test_ended_at { Time.zone.now - 1.minute }
    employee_representative_arrived_at { Time.zone.now }

    before :create do |report|
      report.saved_pictures = rand 50 if report.pictures_saved?
      report.amplifying_comments = FFaker::Lorem.paragraph if rand(20).zero?
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
  end
end
