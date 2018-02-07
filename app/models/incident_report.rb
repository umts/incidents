# frozen_string_literal: true

class IncidentReport < ApplicationRecord
  has_paper_trail

  WEATHER_OPTIONS = %w[Clear Raining Fog Snowing Sleet].freeze
  ROAD_OPTIONS = %w[Dry Wet Icy Snowy Slushy].freeze
  LIGHT_OPTIONS = %w[Daylight Dawn/Dusk Darkness].freeze
  BUS_MOTION_OPTIONS = %w[Stopped Braking Accelerating Other].freeze
  STEP_CONDITION_OPTIONS = %w[Dry Wet Icy Other].freeze
  PASSENGERS_REQUIRED_FIELDS = %i[name address town state zip phone].freeze
  PASSENGER_INCIDENT_LOCATIONS = [
    'Front door', 'Rear door', 'Front steps', 'Rear steps', 'Sudden stop',
    'Before boarding', 'While boarding', 'After boarding', 'While exiting',
    'After exiting'
  ].freeze
  IMPACT_LOCATION_OPTIONS = [
    'Bike rack', 'Windshield', 'Front bumper', 'Driver side front bumper',
    'Curb side front bumper', 'Roof', 'Driver side mirror', 'Curb side mirror',
    'Driver compartment window', 'Front door', 'Front driver side wheel',
    'Front curb side wheel', 'Front driver side passenger windows',
    'Front curb side passenger windows', 'Center driver side passenger windows',
    'Center curb side passenger windows', 'Center driver side body panels',
    'Center curb side body panels', 'Rear door', 'Fuel compartment body panel',
    'Driver side rear duals', 'Curb side rear duals',
    'Driver side rear body panel', 'Curb side rear body panel',
    'Driver side rear passenger windows', 'Curb side rear passenger windows',
    'Rear bumpers', 'Driver side rear bumper', 'Curb side rear bumper',
    'Driver side tail lights', 'Curb side tail lights', 'Rear of bus'
  ].freeze
  SURFACE_TYPE_OPTIONS = %w[Concrete Gravel Oiled Dirt Asphalt Other].freeze
  SURFACE_GRADE_OPTIONS = %w[Smooth Rough Uphill Downhill
                             Level High\ Crowned Banked].freeze
  DIRECTIONS = {
    NORTH: 'North', SOUTH: 'South', EAST: 'East', WEST: 'West',
    INB: 'Inbound', OUTB: 'Outbound', INW: 'Inward', OUTW: 'Outward',
    CW: 'Clockwise', CCW: 'Counterclockwise', DIR1: 'DIR1', DIR2: 'DIR2',
    UPWARD: 'Upward', DOWNWARD: 'Downward', NA: 'N/A or Unknown'
  }.stringify_keys.freeze

  TOWN_OPTIONS = %w[
    Agawam Amherst Chicopee East\ Longmeadow Easthampton Enfield Feeding\ Hills
    Florence Hadley Holyoke Indian\ Orchard Leeds Longmeadow Ludlow Northampton
    South\ Hadley Springfield West\ Springfield Westfield Williamsburg
  ]

  HISTORY_EXCLUDE_FIELDS = %w[id created_at updated_at].freeze

  belongs_to :user
  has_one :incident

  validates :occurred_at, :location, :direction, :town, :bus, presence: true, unless: :new_record?
  validates :run, length: { maximum: 5 }

  def full_location(include_state: false)
    return unless location.present? && town.present?
    parts = [location, town]
    if include_state
      parts << 'MA'
    end
    parts.join ', '
  end

  def incident
    Incident.where(driver_incident_report_id: id)
            .or(Incident.where(supervisor_incident_report_id: id)).first
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

  def long_description?
    description.present? && description.length > 1_000
  end

  def needs_reason_not_up_to_curb?
    motion_of_bus == 'Stopped' && !bus_up_to_curb?
  end

  def occurred_at_readable
    [occurred_date, occurred_time].join ' - '
  end

  def occurred_date
    occurred_at.try :strftime, '%A, %B %e'
  end

  def occurred_time
    occurred_at.try :strftime, '%l:%M %P'
  end

  # rubocop:disable Metrics/LineLength
  def other_vehicle_driver_full_address
    first_line = other_vehicle_driver_address
    second_line = "#{other_vehicle_driver_address_town}, #{other_vehicle_driver_address_state} #{other_vehicle_driver_address_zip}"
    [first_line, second_line]
  end

  def other_vehicle_owner_full_address
    first_line = other_vehicle_owner_address
    second_line = "#{other_vehicle_owner_address_town}, #{other_vehicle_owner_address_state} #{other_vehicle_owner_address_zip}"
    [first_line, second_line]
  end
  # rubocop:enable Metrics/LineLength

  def occurred_full_location
    PASSENGER_INCIDENT_LOCATIONS.select do |loc|
      send(('occurred ' + loc.downcase).tr(' ', '_') + '?')
    end.join ', '
  end

  def occurred_location_matrix
    PASSENGER_INCIDENT_LOCATIONS.map do |loc|
      send(('occurred ' + loc.downcase).tr(' ', '_') + '?')
    end
  end

  def other?
    !(motor_vehicle_collision? || passenger_incident?)
  end

  def report_type
    if self == incident.driver_incident_report
      'Driver'
    else 'Supervisor'
    end
  end

  def type_situation
    if motor_vehicle_collision?
      'ACCIDENT'
    else 'INCIDENT'
    end
  end
end
