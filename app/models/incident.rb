# frozen_string_literal: true

class Incident < ApplicationRecord

  WEATHER_OPTIONS = %w[clear raining fog snowing sleet]
  ROAD_OPTIONS = %w[dry wet icy snowy slushy]
  LIGHT_OPTIONS = %w[daylight dawn/dusk darkness]
  DIRECTION_OPTIONS = %w[North East South West]
  BUS_MOTION_OPTIONS = %w[Stopped Braking Accelerating Other]
  STEP_CONDITION_OPTIONS = %w[Dry Wet Icy Other]

  belongs_to :driver, class_name: 'User', foreign_key: :driver_id
  has_many :staff_reviews, dependent: :destroy

  validates :driver, presence: true

  # validates presence of incident fields
  # validates presence of motor vehicle collision fields, if motor vehicle collision
  # validates presence of passenger incident fields, if passenger incident
  # validates weather conditions inclusion in weather options
  # validates road conditions inclusion in road options
  # validates light conditions inclusion in light options
  # validates direction inclusion in direction options
  # validates presence of police badge if police on scene
  # validates motion of bus in motion options
  # validates condition of steps in step condition options
  # validates presence of reason not up to curb unless bus up to curb
  # serialize injured passengers, Hash
  # validate :injured_passengers_required_fields

  scope :between,
        ->(start_date, end_date) { where occurred_at: start_date..end_date }
  scope :incomplete, -> { where completed: false }
  scope :unreviewed, -> {
    includes(:staff_reviews).where completed: true, staff_reviews: { id: nil }
  }

  def occurred_at_readable
    [occurred_date, occurred_time].join ' '
  end

  def occurred_date
    occurred_at.strftime '%A, %B %e'
  end

  def occurred_time
    occurred_at.strftime '%l:%M %P'
  end

  def reviewed?
    staff_reviews.present?
  end

  # private
  #
  # def injured_passengers_required_fields
  #   # validate that injured passengers each have name, address, and phone
  # end
end
