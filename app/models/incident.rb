# frozen_string_literal: true

class Incident < ApplicationRecord
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

  belongs_to :driver, class_name: 'User', foreign_key: :driver_id
  has_many :staff_reviews, dependent: :destroy

  validates :driver, presence: true

  # INCIDENT FIELDS

  validates :run, :block, :bus, :occurred_at, :passengers_onboard,
            :courtesy_cards_distributed, :courtesy_cards_collected, :speed,
            :location, :town, :weather_conditions, :road_conditions,
            :light_conditions, :description,
            presence: true, if: -> { completed? }
  validates :weather_conditions, inclusion: { in: WEATHER_OPTIONS, allow_blank: true },
                                 if: :completed?
  validates :road_conditions, inclusion: { in: ROAD_OPTIONS, allow_blank: true },
                              if: :completed?
  validates :light_conditions, inclusion: { in: LIGHT_OPTIONS, allow_blank: true },
                               if: :completed?

  # MOTOR VEHICLE COLLISION FIELDS

  validates :other_vehicle_plate, :other_vehicle_state, :other_vehicle_make,
            :other_vehicle_model, :other_vehicle_year, :other_vehicle_color,
            :other_vehicle_passengers, :direction, :other_vehicle_direction,
            :other_driver_name, :other_driver_license_number,
            :other_driver_license_state, :other_vehicle_driver_address,
            :other_vehicle_driver_address_town,
            :other_vehicle_driver_address_state,
            :other_vehicle_driver_address_zip, :other_vehicle_driver_home_phone,
            :damage_to_bus_point_of_impact,
            :damage_to_other_vehicle_point_of_impact,
            :insurance_carrier, :insurance_policy_number,
            :insurance_effective_date,
            presence: true, if: -> {
                                  completed? &&
                                     motor_vehicle_collision? }
  validates :direction, :other_vehicle_direction,
            inclusion: { in: DIRECTION_OPTIONS, allow_blank: true },
            if: -> {
                  completed? &&
                     motor_vehicle_collision? }
  validates :other_vehicle_owner_name, :other_vehicle_owner_address,
            :other_vehicle_owner_address_town,
            :other_vehicle_owner_address_state,
            :other_vehicle_owner_address_zip, :other_vehicle_owner_home_phone,
            presence: true, if: -> {
                                  completed? &&
                                     motor_vehicle_collision? &&
                                     !other_vehicle_owned_by_other_driver? }
  validates :police_badge_number, :police_town_or_state, :police_case_assigned,
            presence: true, if: -> {
                                  completed? &&
                                     motor_vehicle_collision? &&
                                     police_on_scene? }

  # PASSENGER INCIDENT FIELDS

  validates :motion_of_bus, :condition_of_steps,
            presence: true, if: -> {
                                  completed? &&
                                     passenger_incident? }
  validates :motion_of_bus,
            inclusion: { in: BUS_MOTION_OPTIONS, allow_blank: true },
            if: -> {
                  completed? &&
                     passenger_incident? }
  validates :condition_of_steps,
            inclusion: { in: STEP_CONDITION_OPTIONS, allow_blank: true },
            if: -> {
                  completed? &&
                     passenger_incident? }
  validates :reason_not_up_to_curb,
            presence: true, if: -> {
                                  completed? &&
                                     passenger_incident? &&
                                     motion_of_bus == 'Stopped' &&
                                     !bus_up_to_curb? }

  serialize :injured_passenger, Hash
  validates :injured_passenger,
            presence: true, if: -> { completed? &&
                                      passenger_incident? &&
                                      passenger_injured? }
  validate :injured_passenger_required_fields,
           if: -> { completed? &&
                     passenger_incident? &&
                     passenger_injured? }

  scope :between,
        ->(start_date, end_date) { where occurred_at: start_date..end_date }
  scope :incomplete, -> { where completed: false }
  scope :unreviewed, -> {
    includes(:staff_reviews).where completed: true, staff_reviews: { id: nil }
  }

  def injured_passenger_full_address
    injured_passenger.values_at(:address, :town, :state, :zip).join ', '
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
    end.join ','
  end

  def occurred_location_matrix
    PASSENGER_INCIDENT_LOCATIONS.map do |loc|
      send(('occurred ' + loc.downcase).tr(' ', '_') + '?')
    end
  end

  def other?
    !(motor_vehicle_collision? || passenger_incident?)
  end

  def reviewed?
    staff_reviews.present?
  end

  private

  def injured_passenger_required_fields
    pax = injured_passenger
    return if PASSENGERS_REQUIRED_FIELDS.all? { |key| pax[key].present? }
    errors.add :injured_passenger,
               "must have #{PASSENGERS_REQUIRED_FIELDS.to_sentence}"
  end
end
