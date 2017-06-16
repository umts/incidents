class Incident < ApplicationRecord
  has_paper_trail

  belongs_to :driver_incident_report, class_name: 'IncidentReport',
    foreign_key: :driver_incident_report_id
  belongs_to :supervisor_incident_report, class_name: 'IncidentReport',
    foreign_key: :supervisor_incident_report_id
  belongs_to :supervisor_report

  has_one :driver, through: :driver_incident_report, source: :user
  has_one :supervisor, through: :supervisor_incident_report, source: :user

  scope :between,
        ->(start_date, end_date) { where occurred_at: start_date..end_date }
  scope :incomplete, -> { where completed: false }
  scope :unreviewed, -> {
    includes(:staff_reviews).where completed: true, staff_reviews: { id: nil }
  }

end
