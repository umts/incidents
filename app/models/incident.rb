class Incident < ApplicationRecord
  belongs_to :driver, class_name: 'User', foreign_key: :driver_id
  validates :driver, presence: true

  scope :between,
        -> (start_date, end_date) { where occurred_at: start_date..end_date }
  scope :incomplete, -> { where completed: false }

  def occurred_date
    occurred_at.strftime '%A, %B %e'
  end

  def occurred_time
    occurred_at.strftime '%l:%M %P'
  end
end
