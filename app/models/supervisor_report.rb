# frozen_string_literal: true

class SupervisorReport < ApplicationRecord
  has_paper_trail

  REASONS_FOR_TEST = [
    'Post Accident: Threshold met (completed drug test)',
    'Post Accident: No threshold met (no drug test)',
    'Post Accident: Threshold met and discounted (no drug test)',
    'Reasonable Suspicion: Completed drug test'
  ].freeze
  TESTING_FACILITIES = [
    'Occuhealth East Longmeadow',
    'Occuhealth Northampton',
    'On-Site (Employee Work Location)'
  ].freeze

  HISTORY_EXCLUDE_FIELDS = %w[id created_at updated_at].freeze

  validates :test_status, inclusion: { in: REASONS_FOR_TEST,
                                                 allow_blank: true }
  validates :reason_driver_discounted, presence: { if: :driver_discounted? }
  validates :reason_threshold_not_met, presence: { if: :fta_threshold_not_met? }
  has_one :incident

  has_many :witnesses
  accepts_nested_attributes_for :witnesses

  before_save do
    unless fta_threshold_not_met?
      assign_attributes reason_threshold_not_met: nil
    end
  end

  before_save do
    unless driver_discounted?
      assign_attributes reason_driver_discounted: nil
    end
  end

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

  def additional_comments
    if completed_drug_or_alcohol_test?
      amplifying_comments
    else fta_justifications
    end
  end

  def fta_justifications
    sections = []
    if reason_threshold_not_met.present?
      sections << "Reason FTA threshold not met: #{reason_threshold_not_met}"
    end
    if reason_driver_discounted.present?
      sections << "Reason driver was discounted: #{reason_driver_discounted}"
    end
    sections.join("\n")
  end

  def has_witnesses?
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
