# frozen_string_literal: true

class IncidentReport < ApplicationRecord
  has_paper_trail

  WEATHER_OPTIONS = %w[Clear Raining Fog Snowing Sleet].freeze
  ROAD_OPTIONS = %w[Dry Wet Icy Snowy Slushy].freeze
  LIGHT_OPTIONS = %w[Daylight Dawn/Dusk Darkness].freeze
  DIRECTION_OPTIONS = %w[North East South West].freeze
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
  SURFACE_GRADE_OPTIONS = %w[Smooth Rough Uphill Downhill Level High\ Crowned Banked].freeze

  HISTORY_EXCLUDE_FIELDS = %w[id created_at updated_at].freeze

  belongs_to :user
  has_one :incident

  serialize :injured_passenger, Hash

  validate :injured_passenger_required_fields,
           if: -> { passenger_incident? && passenger_injured? }
  before_save do
    self.injured_passenger = {} unless passenger_injured?
  end

  def incident
    Incident.where(driver_incident_report_id: id).or(Incident.where(supervisor_incident_report_id: id)).first
  end

  def injured_passenger_full_address
    injured_passenger.values_at(:address, :town, :state, :zip).join ', '
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


  private

  def injured_passenger_required_fields
    pax = injured_passenger
    return if PASSENGERS_REQUIRED_FIELDS.all? { |key| pax[key].present? }
    errors.add :injured_passenger,
               "must have #{PASSENGERS_REQUIRED_FIELDS.to_sentence}"
  end
end
