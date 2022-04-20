# frozen_string_literal: true

class SupervisorReport < ApplicationRecord
  has_paper_trail

  REASONS_FOR_TEST = {
    'Post Accident: Threshold met (completed drug test)' => 'Reason(s) FTA threshold was met: ',
    'Post Accident: No threshold met (no drug test)' => 'Reason(s) FTA threshold not met: ',
    'Post Accident: Threshold met and discounted (no drug test)' => 'Reason(s) driver was discounted: ',
    'Reasonable Suspicion: Completed drug test' => 'Reason(s) for suspicion: '
  }.freeze

  TESTING_FACILITIES = [
    'Occuhealth East Longmeadow',
    'Occuhealth Northampton',
    'On-Site (Employee Work Location)'
  ].freeze

  HISTORY_EXCLUDE_FIELDS = %w[id created_at updated_at].freeze

  validates :test_status, inclusion: { in: REASONS_FOR_TEST, allow_blank: true }
  validates :amplifying_comments, presence: { if: :test_status? }

  has_one :incident
  has_many :witnesses
  accepts_nested_attributes_for :witnesses

  before_save do
    unless post_accident_completed_drug_test?
      assign_attributes test_due_to_bodily_injury: false,
                        test_due_to_disabling_damage: false,
                        test_due_to_fatality: false
    end
  end

  before_save do
    unless reasonable_suspicion?
      assign_attributes completed_drug_test: false,
                        completed_alcohol_test: false,
                        observation_made_at: false,
                        test_due_to_employee_appearance: false,
                        test_due_to_employee_behavior: false,
                        test_due_to_employee_speech: false,
                        test_due_to_employee_odor: false
    end
  end

  def fta_justifications
    REASONS_FOR_TEST[test_status] + amplifying_comments
  end

  def witnesses?
    witnesses.present? && witnesses.any?(&:persisted?)
  end

  def last_update
    versions.last
  end

  def last_updated_at
    last_update.created_at.strftime '%A, %B %e - %l:%M %P'
  end

  def last_updated_by
    User.find_by(id: last_update.whodunnit).try(:name) || 'Unknown'
  end

  def post_accident_completed_drug_test?
    test_status.try(:include?, 'Threshold met (completed drug test)')
  end

  def reasonable_suspicion?
    test_status.try(:include?, 'Reasonable Suspicion')
  end

  def fta_threshold_not_met?
    test_status.try(:include?, 'No threshold met')
  end

  def driver_discounted?
    test_status.try(:include?, 'discounted')
  end

  def no_drug_test?
    test_status.try(:include, 'no drug test')
  end

  def post_accident?
    test_status.try(:include?, 'completed drug test')
  end

  def timeline
    events = {}
    %w[
      testing_facility_notified
      employee_representative_notified
      employee_representative_arrived
      employee_notified_of_test
      employee_departed_to_test
      employee_arrived_at_test
      test_started
      test_ended
      employee_returned_to_work_or_released_from_duty
      superintendent_notified
      program_manager_notified
      director_notified
    ].each do |method|
      time = send "#{method}_at"
      events[method] = time
    end
    format_timeline(events)
  end

  private

  def format_timeline(events)
    events.map do |method, time|
      "#{method.humanize.capitalize}: #{time.try :strftime, '%-l:%M %P'}"
    end
  end
end
