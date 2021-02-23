# frozen_string_literal: true

require 'csv'

class Incident < ApplicationRecord
  CLAIMS_XML_DIR = Rails.root.join('claims_xml')

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
  validates :occurred_at, presence: true, on: :create, if: :created_by_supervisor
  delegate :occurred_at_readable, to: :driver_incident_report
  delegate :occurred_at, to: :driver_incident_report
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

  def export_claims_xml(current_user)
    report = driver_incident_report
    builder = Nokogiri::XML::Builder.new do |doc|
      doc.claims_incident_data do
        doc.drivers_report do
          doc.incident_date       report.occurred_at.iso8601
          doc.street              report.location
          doc.city                report.town
          doc.state               report.state
          doc.zip                 report.zip
          doc.longitude           longitude
          doc.latitude            latitude
          doc.company             driver.division.claims_id
          doc.driver_desc         report.description
          doc.employee_entering   current_user.badge_number
          doc.driver              driver.badge_number
          doc.run_number          report.route
          doc.vehicle_num         report.bus
          doc.speed               report.speed
          doc.incident_desc       supervisor_incident_report.try(:description)
          doc.point_of_contact    report.damage_to_bus_point_of_impact
          doc.reason1             reason_code.identifier
          doc.reason2             supplementary_reason_code.try(:identifier)
          doc.weather             report.weather_conditions
          doc.surr_cond           report.road_conditions
          doc.lighting            report.light_conditions
          doc.direction           report.direction
          doc.curb_distance       supervisor_incident_report.try(:curb_distance)
          doc.vehicle_distance    report.vehicle_distance
          doc.total_pass          report.passengers_onboard
          doc.preventable         preventable
          doc.police_on_scene     report.police_on_scene
          doc.officer_info_taken  report.police_badge_number.present?
          doc.citation            report.summons_or_warning_issued?
          doc.wheelchair_involved report.wheelchair_involved
          doc.ambulance           report.injured_passengers.any?(&:transported_to_hospital?)
          doc.pvta_tow            report.towed_from_scene?
          doc.ov_tow              report.other_vehicle_towed_from_scene?
          doc.fatality            supervisor_report.try(:test_due_to_fatality)
          doc.other_vehicle_info_taken   report.other_vehicle_plate.present?
          doc.other_driver_info_taken    report.other_driver_license_number.present?
          doc.other_passenger_info_taken report.other_passenger_information_taken
          doc.pvta_passenger_info_taken  report.pvta_passenger_information_taken
          doc.property_owner_info_taken  report.property_owner_information_taken
          doc.witness_info_taken         supervisor_report.try(:witnesses).present?
          doc.assistance_requested       report.assistance_requested
          doc.chair_on_lift       report.chair_on_lift
          doc.lift_deployed       report.lift_deployed
        end
      end
    end
    File.open File.join(CLAIMS_XML_DIR, "#{id}.xml"), 'w' do |xml_file|
      xml_file.puts builder.to_xml
    end
  end

  def export_to_claims(current_user)
    if completed? && valid?
      export_claims_xml(current_user)
      self.update exported_to_claims: true
      return { status: :success }
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
        .new_incident.deliver_later
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
                       .new_incident.deliver_later
    end
  end

  def created_by_supervisor
    supervisor_incident_report.present?
  end
end
