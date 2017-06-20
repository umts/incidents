class Incident < ApplicationRecord
  has_paper_trail

  belongs_to :driver_incident_report, class_name: 'IncidentReport',
    foreign_key: :driver_incident_report_id
  belongs_to :supervisor_incident_report, class_name: 'IncidentReport',
    foreign_key: :supervisor_incident_report_id
  belongs_to :supervisor_report

  has_one :driver, through: :driver_incident_report, source: :user
  validates :driver, inclusion: { in: ->(_) { User.drivers } }
  has_one :supervisor, through: :supervisor_incident_report, source: :user
  validates :supervisor, inclusion: { in: ->(_) { User.supervisors } }

  accepts_nested_attributes_for :driver_incident_report
  accepts_nested_attributes_for :supervisor_incident_report
  accepts_nested_attributes_for :supervisor_report

  has_many :staff_reviews, dependent: :destroy

  scope :between,
        ->(start_date, end_date) { where occurred_at: start_date..end_date }
  scope :for_driver, (lambda do |user|
    joins(:driver_incident_report)
      .where(incident_reports: { user_id: user.id })
  end)
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

end
