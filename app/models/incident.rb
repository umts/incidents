class Incident < ApplicationRecord
  belongs_to :driver, class_name: 'User', foreign_key: :driver_id
  validates :driver, presence: true

  validates :shift, :route, :vehicle, :location, :action_before,
            :action_during, :weather_conditions, :light_conditions,
            :road_conditions, :description,
            presence: true, if: :completed?

  scope :between,
        -> (start_date, end_date) { where occurred_at: start_date..end_date }
  scope :incomplete, -> { where completed: false }

  def occurred_at_readable
    [occurred_date, occurred_time].join ' '
  end

  def occurred_date
    occurred_at.strftime '%A, %B %e'
  end

  def occurred_time
    occurred_at.strftime '%l:%M %P'
  end
end
