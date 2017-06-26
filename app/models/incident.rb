class Incident < ApplicationRecord
  has_paper_trail

  belongs_to :driver_incident_report, class_name: 'IncidentReport',
    foreign_key: :driver_incident_report_id
  belongs_to :supervisor_incident_report, class_name: 'IncidentReport',
    foreign_key: :supervisor_incident_report_id
  belongs_to :supervisor_report
  # I wish there were a way to write this as a one-liner, e.g.
  # belongs_to :reason_code, optional: { unless: :completed? }
  belongs_to :reason_code, optional: true
  validates :reason_code, presence: true, if: :completed?

  has_one :driver, through: :driver_incident_report, source: :user
  has_one :supervisor, through: :supervisor_incident_report, source: :user
  validate :driver_and_supervisor_in_correct_groups

  accepts_nested_attributes_for :driver_incident_report
  accepts_nested_attributes_for :supervisor_incident_report
  accepts_nested_attributes_for :supervisor_report

  has_many :staff_reviews, dependent: :destroy

  scope :between,
        ->(start_date, end_date) { where occurred_at: start_date..end_date }
  scope :for_driver, -> (user) {
    joins(:driver_incident_report)
      .where(incident_reports: { user_id: user.id })
  } 
  scope :for_supervisor, -> (user) {
    joins(:supervisor_incident_report)
      .where(incident_reports: { user_id: user.id })
  } 
  scope :incomplete, -> { where completed: false }
  scope :unreviewed, -> {
    includes(:staff_reviews).where completed: true, staff_reviews: { id: nil }
  }


  def occurred_at_readable
    [occurred_date, occurred_time].join ' - '
  end

  def occurred_date
    occurred_at.try :strftime, '%A, %B %e'
  end

  def occurred_time
    occurred_at.try :strftime, '%l:%M %P'
  end

  def reviewed?
    staff_reviews.present?
  end

  private

  def driver_and_supervisor_in_correct_groups
    unless driver_incident_report.user.driver?
      errors.add :driver_incident_report,
                 'Selected driver is not a driver'
    end
    unless supervisor_incident_report.user.supervisor?
      errors.add :supervisor_incident_report,
                 'Selected supervisor is not a supervisor'
    end
  end

end
