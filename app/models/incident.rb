# frozen_string_literal: true

require 'csv'

class Incident < ApplicationRecord
  has_paper_trail

  SECOND_REASON_CODES = [
    'a-1: Line Service - Stopped',
    'a-2: Line Service - In Traffic, Moving',
    'a-3: Stop - Exit',
    'a-4: Stop - Enter',
    'a-5: At Stop',
    'a-6: Right Turn',
    'a-7: Left Turn',
    'a-8: Miscellaneous',
    'b-1: Line Service - Stopped',
    'b-2: Line Service - In Traffic, Moving',
    'b-3: Stop - Exit',
    'b-4: Stop - Enter',
    'b-5: At Stop',
    'b-6: Right Turn',
    'b-7: Left Turn',
    'b-8: Miscellaneous'
  ]

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
  validates :reason_code, :second_reason_code, :root_cause_analysis, :latitude, :longitude,
    presence: true, if: :completed?
  validates :second_reason_code,
    inclusion: { in: SECOND_REASON_CODES, allow_blank: true },
    if: :completed?

  has_one :driver, through: :driver_incident_report, source: :user
  delegate :division, to: :driver
  has_one :supervisor, through: :supervisor_incident_report, source: :user
  validate :supervisor_in_correct_group

  accepts_nested_attributes_for :driver_incident_report
  delegate :occurred_at_readable, to: :driver_incident_report
  accepts_nested_attributes_for :supervisor_incident_report
  accepts_nested_attributes_for :supervisor_report

  has_many :staff_reviews, dependent: :destroy

  scope :between, (lambda do |start_date, end_date| 
    joins(:driver_incident_report)
      .where incident_reports: { occurred_at: start_date..end_date }
  end)

  scope :in_divisions, (lambda do |divisions|
    joins(driver: :divisions_users)
      .where divisions_users: { division_id: divisions.pluck(:id) }
  end)

  scope :occurred_order, (lambda do
    joins(:driver_incident_report).order 'incident_reports.occurred_at'
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
    save! validate: false
  end

  def geocode_location
    driver_incident_report.full_location include_state: true
  end

  def mark_as_exported
    self.exported = true
    save! validate: false
  end

  def notify_supervisor_of_new_report
    if supervisor.email.present?
      ApplicationMailer.with(incident: self, destination: supervisor.email)
        .new_incident.deliver_now
    end
  end

  def remove_supervisor
    self.supervisor_report = nil
    self.supervisor_incident_report = nil
    save
  end

  def reviewed?
    staff_reviews.present?
  end

  # from https://gist.github.com/janko-m/2b2cea3e8e21d9232fb9
  def to_claims_sql(table:)
    report = driver_incident_report

    fields = {
      incident: {
        street: report.location,
        city: report.town,
        state: 'MA',
        # zip: driver.incident_report.zip,
        longitude: longitude,
        latitude: latitude,
        'IncidentDesc' => root_cause_analysis,
        'VehicleRouteNum' => report.block,
        'VehicleNum' => 777, # will be pulled from claims table
        'PointOfContact' => report.damage_to_bus_point_of_impact,
        'Status' => 'ir',
        reason1: reason_code.identifier,
        reason2: second_reason_code.try(:first, 3),
        'Company' => driver.division.claims_id,
        'DateEntered' => Date.today.strftime('%Y-%m-%d'),
        'IncidentDate' => report.occurred_at,
        'EmployeeID' => driver.badge_number,
        'Driver' => 999, # will be pulled from claims table
        'DriverDesc' => report.description,
      },
      drivers_report: {
        'Speed' => report.speed,
        'Weather' => report.weather_conditions,
        'Lighting' => report.light_conditions,
        'PointOfContact' => report.damage_to_bus_point_of_impact,
        'FileID' => 888, # will be pulled from corresponding claims record
        'TotalPass' => report.passengers_onboard,
        # 'Ambulance' => report.injured_passengers.any?(&:transported_to_hospital?)
      },
    }.fetch(table)

    arel_insert_statement(table, fields)
  end

  def to_csv
    CSV.generate do |csv|
      row = []
      report = driver_incident_report
      row << report.occurred_at.strftime('%m/%d/%Y') # Date
      row << report.bus # Bus
      row << "#{driver.badge_number} | #{driver.proper_name.upcase}" # Badge # and Operator
      row << report.occurred_at.strftime('%H:%M:%S') # Time
      row << report.full_location # Location
      row << report.run # Route
      row << reason_code.try(:identifier) || "" # Classification 1
      row << second_reason_code.try(:first, 3) # Classification 2
      # AVOIDABLE, UNAVOIDABLE, OTHER VEHICLE, PEDESTRIAN, BICYCLE,
      # STATIONARY OBJ, STATIONARY VEH, COMPANY VEH, BOARDING, ALIGHTING,
      # ONBOARD, THROWN IN BUS, INJURED ON BUS, CAUGHT IN DOOR, MISC,
      # AMB REQUESTED, # OF INJURED
      row += [""] * 17
      row << report.block # Block
      row << root_cause_analysis
      # Video File Name
      row << ""
      classification = if report.passenger_incident? then 'Passenger Incident'
                       elsif report.motor_vehicle_collision? then 'Collision'
                       else 'Other'
                       end
      row << classification # Collision or Passenger Incident
      csv << row
    end
  end

  def unclaimed?
    !completed? && supervisor_incident_report.nil?
  end

  private

  def arel_insert_statement(table_name, fields)
    remote_table = Arel::Table.new(table_name)
    insert = Arel::InsertManager.new
    fields.each_key { |column| insert.columns << remote_table[column] }
    insert.values = Arel::Nodes::Values.new(fields.values)
    insert.into(remote_table).to_sql
  end

  def supervisor_in_correct_group
    unless supervisor_incident_report.blank? ||
           supervisor_incident_report.try(:user).try(:supervisor?)
      errors.add :supervisor_incident_report,
                 'selected supervisor is not a supervisor'
    end
  end

  def send_notifications
    User.staff.in_divisions(driver.divisions).with_email.each do |user|
      ApplicationMailer.with(incident: self, destination: user.email)
                       .new_incident.deliver_now
    end
  end
end
