# frozen_string_literal: true

require 'csv'

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
  belongs_to :supplementary_reason_code, optional: true
  validates :reason_code, :supplementary_reason_code, :root_cause_analysis, :latitude, :longitude,
    presence: true, if: :completed?

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

  def csv_row
    row = []
    report = driver_incident_report
    row << report.occurred_at.strftime('%m/%d/%Y') # Date
    row << report.bus # Bus
    row << "#{driver.badge_number} | #{driver.proper_name.upcase}" # Badge # and Operator
    row << report.occurred_at.strftime('%H:%M:%S') # Time
    row << report.full_location # Location
    row << report.run # Route
    row << reason_code.try(:identifier) || "" # Classification 1
    row << supplementary_reason_code.try(:identifier) # Classification 2
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
    row
  end

  def export_to_claims!
    if completed? && valid?
      begin
        ci = ClaimsIncident.create claims_fields table: :incident
        update claims_id: ci.UID
        ClaimsDriversReport.create claims_fields table: :drivers_report
        self.update exported_to_claims: true
        return { status: :success }
      rescue ActiveRecord::StatementInvalid => e
        # We only get here if an error was caused by a programmer.
        ApplicationMailer.with(incident: self, cause: e.cause)
                         .claims_export_error.deliver_now
        return { status: :failure, reason: e.cause }
      end
    else
      self.update completed: false
      return { status: :invalid }
    end
  end

  def geocode_location
    driver_incident_report.full_location include_state: true
  end

  def mark_as_exported_to_hastus
    self.exported_to_hastus = true
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

  # Fields we can't provide are commented where they appear in the claims schema.
  # Field we're not providing in the first stage are implemented but commented.
  def claims_fields(table:)
    report = driver_incident_report

    # define associated records only when necessary
    case table
    when :incident
      claims_driver = ClaimsDriver.find_by BadgeNum: driver.badge_number
      claims_vehicle = ClaimsVehicle.find_by VehicleNum: report.bus, Active: 'yes'
    end

    fields = {
      incident: {
        # FilePrefix, FileNum
        'DateEntered' => Date.today.strftime('%Y-%m-%d'),
        # AppraisalMade, AppraisalNote
        'IncidentDate' => report.occurred_at.iso8601,
        street: report.location,
        city: report.town,
        state: 'MA',
        zip: report.zip,
        longitude: longitude,
        latitude: latitude,
        # AccidentCode, AccidentCodeGroup
        'Company' => driver.division.claims_id,
        'IncidentDesc' => supervisor_incident_report.try(:description),
        'EmployeeID' => driver.badge_number,
        'Driver' => claims_driver.try(:UID),
        'DriverDesc' => report.description,
        'VehicleRouteNum' => report.route,
        # VehicleDestination
        'VehicleNum' => claims_vehicle.try(:UID),
        # VehicleAppraisalAmnt
        'VehicleDamageArea' => report.damage_to_other_vehicle_point_of_impact,
        # Comments, ReportGiver
        'PointOfContact' => report.damage_to_bus_point_of_impact,
        # TotalSettlement
        'Status' => 'ir',
        # CloseDate, ReopenDate, DownDate, ac_type
        reason1: reason_code.identifier,
        reason2: supplementary_reason_code.try(:identifier),
      },
      drivers_report: {
        'FileID' => claims_id,
      # 'PolicePresent' => report.police_on_scene?,
        # OfficerName
      # 'BadgeNum' => report.police_badge_number,
        # ArrivalTime
        'Citation' => report.summons_or_warning_issued?,
      # 'CitationWho' => report.summons_or_warning_info,
        'Weather' => report.weather_conditions,
        'SurrCond' => report.road_conditions,
        'Lighting' => report.light_conditions,
        # LossLocation
        'Speed' => report.speed,
      #  'MotionBus' => report.motion_of_bus,
      # 'Direction' => report.direction,
        # ChairOnLift, LiftDeployed, PassengersPresent, SeatBelts
        'PointOfContact' => report.damage_to_bus_point_of_impact,
      # 'CurbDist' => report.bus_distance_from_curb,
        # VehicleDistance, ReviewFlg
        'TotalPass' => report.passengers_onboard,
        # PVTAatFault, Wheelchair, YellowLine, NotReported
        'Ambulance' => report.injured_passengers.any?(&:transported_to_hospital?),
        'OVTow' => report.other_vehicle_towed_from_scene?,
        'PVTATow' => report.towed_from_scene?,
        # Fatality, assistRequest, PD, Note, externalAppraisal
      },
    }
    
    fields.fetch(table)
  end

  def to_csv
    CSV.generate do |csv|
      csv << csv_row
    end
  end

  def self.to_csv
    CSV.generate do |csv|
      all.each do |incident|
        csv << incident.csv_row
      end
    end
  end

  def unclaimed?
    !completed? && supervisor_incident_report.nil?
  end

  private
  
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
