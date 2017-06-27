class SupervisorReport < ApplicationRecord
  has_paper_trail

  REASONS_FOR_TEST = ['Post-Accident', 'Reasonable Suspicion']
  TESTING_FACILITIES = [
    'Occuhealth East Longmeadow',
    'Occuhealth Northampton',
    'On-Site (Employee Work Location)'
  ]

  belongs_to :user
  validates :user, inclusion: { in: Proc.new { User.supervisors } }
  validates :reason_test_completed, inclusion: { in: REASONS_FOR_TEST,
                                                 allow_blank: true }
  has_one :incident

  def last_update
    versions.last
  end

  def last_updated_at
    last_update.created_at.strftime '%A, %B %e - %l:%M %P'
  end

  def last_updated_by
    User.find_by(id: last_update.whodunnit).try(:name) || 'Unknown'
  end

  def reasonable_suspicion?
    reason_test_completed == 'Reasonable Suspicion'
  end

  def post_accident?
    reason_test_completed == 'Post-Accident'
  end

  def timeline
    sequence = {}
    %w[
      testing_facility_notified
      employee_notified_of_test
      employee_departed_to_test
      employee_arrived_at_test
      test_started
      test_ended
      employee_returned
      superintendent_notified
      program_manager_notified
      director_notified
    ].each do |method|
      time = send "#{method}_at"
      sequence[method] = time if time.present?
    end
    sequence.sort_by{ |method, time| time }.map do |method, time|
      [time.strftime('%-l:%M %P'), method.humanize.capitalize].join ': '
    end
  end
end
