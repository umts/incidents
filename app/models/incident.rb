# frozen_string_literal: true

class Incident < ApplicationRecord
  has_paper_trail

  belongs_to :driver_incident_report,
             class_name: 'IncidentReport',
             foreign_key: :driver_incident_report_id
  belongs_to :supervisor_incident_report,
             class_name: 'IncidentReport',
             foreign_key: :supervisor_incident_report_id,
             optional: true
  belongs_to :supervisor_report, optional: true
  validates :supervisor_report,
            presence: { if: ->(_inc) { supervisor_incident_report.present? } }
  # I wish there were a way to write this as a one-liner, e.g.
  # belongs_to :reason_code, optional: { unless: :completed? }
  belongs_to :reason_code, optional: true
  validates :reason_code, presence: true, if: :completed?

  has_one :driver, through: :driver_incident_report, source: :user
  delegate :division, to: :driver
  has_one :supervisor, through: :supervisor_incident_report, source: :user
  validate :driver_and_supervisor_in_correct_groups

  accepts_nested_attributes_for :driver_incident_report
  delegate :occurred_at_readable, to: :driver_incident_report
  accepts_nested_attributes_for :supervisor_incident_report
  accepts_nested_attributes_for :supervisor_report

  has_many :staff_reviews, dependent: :destroy

  scope :between, (lambda do |start_date, end_date| 
    joins(:driver_incident_report)
      .where incident_reports: { occurred_at: start_date..end_date }
  end)

  scope :for_driver, ->(user) {
    joins(:driver_incident_report)
      .where(incident_reports: { user_id: user.id })
  }
  scope :for_supervisor, ->(user) {
    joins(:supervisor_incident_report)
      .where(incident_reports: { user_id: user.id })
  }
  scope :incomplete, -> { where completed: false }
  scope :completed, -> { where completed: true }
  scope :unclaimed, -> { incomplete.where supervisor_incident_report_id: nil }

  # It turns out that with MySQL, this *is* case-insensitive.
  scope :by_claim, ->(number) {
    where claim_number: number
  }

  after_create :send_notifications

  def claim_for(user)
    self.supervisor_incident_report = create_supervisor_incident_report user: user
    self.supervisor_report = create_supervisor_report
    save!
  end

  def notify_supervisor_of_new_report
    ApplicationMailer.with(incident: self, destination: supervisor.email)
      .new_incident.deliver_now
  end

  def reviewed?
    staff_reviews.present?
  end

  def unclaimed?
    !completed? && supervisor_incident_report.nil?
  end

  private

  def driver_and_supervisor_in_correct_groups
    unless driver_incident_report.user.driver?
      errors.add :driver_incident_report,
                 'selected driver is not a driver'
    end
    unless supervisor_incident_report.blank? ||
           supervisor_incident_report.try(:user).try(:supervisor?)
      errors.add :supervisor_incident_report,
                 'selected supervisor is not a supervisor'
    end
  end

  def send_notifications
    User.staff.with_email.each do |user|
      ApplicationMailer.with(incident: self, destination: user.email)
                       .new_incident.deliver_now
    end
  end
end
