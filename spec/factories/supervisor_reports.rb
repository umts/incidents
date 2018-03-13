# frozen_string_literal: true

FactoryBot.define do
  factory :supervisor_report do
    pictures_saved { [true, false].sample }
    passenger_statement { FFaker::Lorem.paragraphs(5).join "\n" }
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
      report.saved_pictures = rand 50 if report.pictures_saved?

      if rand(20).zero?
        report.amplifying_comments = FFaker::Lorem.paragraph
      end

      rand(3).times do
        create :witness, supervisor_report: report
      end

      rand(3).times do
        create :injured_passenger, supervisor_report: report
      end

      if report.completed_drug_or_alcohol_test?
        case report.reason_test_completed
        when 'Post-Accident'
          field = %w[
            test_due_to_bodily_injury
            test_due_to_disabling_damage
            test_due_to_fatality
          ].sample
          report.send field + '=', true
        when 'Reasonable Suspicion'
          report.observation_made_at = Time.zone.now - 5.minutes
          reason = %w[appearance behavior speech odor].sample
          report.send "test_due_to_employee_#{reason}=", true
          report.send "employee_#{reason}=", FFaker::Lorem.sentence
        end
      elsif [true, false].sample
        report.fta_threshold_not_met = true
        report.reason_threshold_not_met = FFaker::Lorem.sentence
      else
        report.driver_discounted = true
        report.reason_driver_discounted = FFaker::Lorem.sentence
      end
    end
  end
end
