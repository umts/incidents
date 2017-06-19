# frozen_string_literal: true

FactoryGirl.define do
  factory :supervisor_report do
    association :user, factory: %i[user supervisor]
    hard_drive_pulled { [true, false].sample }
    pictures_saved { [true, false].sample }
    passenger_statement { FFaker::BaconIpsum.paragraphs(5).join "\n" }
    faxed { [nil, Time.zone.now].sample }
    completed_drug_or_alcohol_test { [true, true, false].sample }
    completed_drug_test { [true, false].sample }
    completed_alcohol_test { [true, false].sample }
    reason_test_completed { SupervisorReport::REASONS_FOR_TEST.sample }
    testing_facility { SupervisorReport::TESTING_FACILITIES.sample }
    testing_facility_notified_at { Time.zone.now - 6.minutes }
    employee_notified_of_test_at { Time.zone.now - 5.minutes }
    employee_departed_to_test_at { Time.zone.now - 4.minutes }
    employee_arrived_at_test_at { Time.zone.now - 3.minutes }
    test_started_at { Time.zone.now - 2.minutes }
    test_ended_at { Time.zone.now - 1.minute }
    employee_returned_at { Time.zone.now }

    before :create do |report|
      if report.hard_drive_pulled?
        report.hard_drive_pulled_at = Time.zone.now
        report.hard_drive_removed = rand(100).to_s
        report.hard_drive_replaced = rand(100).to_s
      end

      if report.pictures_saved?
        report.saved_pictures = rand 50
      end
      
      if rand(20).zero?
        report.amplifying_comments = FFaker::BaconIpsum.paragraph
      end

      case report.reason_test_completed
      when 'Post-Accident'
        field = %w[
          test_not_conducted
          test_due_to_bodily_injury
          test_due_to_disabling_damage
          test_due_to_fatality
        ].sample
        report.send field + '=', true
      when 'Reasonable Suspicion'
        report.observation_made_at = Time.zone.now - 5.minutes
        reason = %w[appearance behavior speech odor].sample
        report.send "test_due_to_employee_#{reason}=", true
        report.send "employee_#{reason}=", FFaker::BaconIpsum.sentence
      end
    end
  end
end
