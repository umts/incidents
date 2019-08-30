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
  #validate :documentation_provided_for_no_test,
   # unless: :completed_drug_or_alcohol_test?
  #validates :reason_threshold_not_met, presence: { if: :fta_threshold_not_met? }
  #validates :reason_driver_discounted, presence: { if: :driver_discounted? }
  has_one :incident

  has_many :witnesses
  accepts_nested_attributes_for :witnesses

  before_save do
    # Post-accident tests always complete both kinds.
    if completed_drug_or_alcohol_test? && post_accident?
      assign_attributes completed_drug_test: true,
        completed_alcohol_test: true
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

  def reasonable_suspicion?
    test_status.try(:include?, 'Reasonable Suspicion')
  end

  def post_accident?
      test_status.try(:include?, 'Post-Accident')
  end

  def timeline
    events = {}
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
      events[method] = time
    end
    format_timeline(events)
  end

  private
  
  def documentation_provided_for_no_test
    unless new_record? || fta_threshold_not_met? || driver_discounted?
      errors.add :base, 'You must provide a reason why no test was conducted.'
    end
  end

  def format_timeline(events)
    events.map do |method, time|
      "#{method.humanize.capitalize}: #{time.try :strftime, '%-l:%M %P'}"
    end
  end
end
