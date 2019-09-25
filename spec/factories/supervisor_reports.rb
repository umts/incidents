# frozen_string_literal: true

FactoryBot.define do
  factory :supervisor_report do
    pictures_saved { [true, false].sample }
    passenger_statement { FFaker::Lorem.paragraphs(5).join "\n" }
    faxed { [nil, Time.zone.now].sample }
    test_status { SupervisorReport::REASONS_FOR_TEST.sample }
    testing_facility { SupervisorReport::TESTING_FACILITIES.sample }
    testing_facility_notified_at { Time.zone.now - 6.minutes }
    employee_notified_of_test_at { Time.zone.now - 5.minutes }
    employee_departed_to_test_at { Time.zone.now - 4.minutes }
    employee_arrived_at_test_at { Time.zone.now - 3.minutes }
    test_started_at { Time.zone.now - 2.minutes }
    test_ended_at { Time.zone.now - 1.minute }
    employee_returned_at { Time.zone.now }

    before :create do |report|
      report.saved_pictures = rand 50 if report.pictures_saved?

      if rand(20).zero?
        report.amplifying_comments = FFaker::Lorem.paragraph
      end

      rand(3).times do
        create :witness, supervisor_report: report
      end
      if report.test_status.include?('Post-Accident: Threshold met (completed drug test)')
        field = %w[
          test_due_to_bodily_injury
          test_due_to_disabling_damage
          test_due_to_fatality
        ].sample
        report.send field + '=', true
      elsif report.test_status.include?('Reasonable Suspicion: Completed drug test')
        report.observation_made_at = Time.zone.now - 5.minutes
        reason = %w[appearance behavior speech odor].sample
        report.send "test_due_to_employee_#{reason}=", true
        report.send "employee_#{reason}=", FFaker::Lorem.sentence
      elsif report.fta_threshold_not_met?
        report.reason_threshold_not_met = FFaker::Lorem.sentence
      else
        report.reason_driver_discounted = FFaker::Lorem.sentence
      end
    end
  end
end
