class Incident < ApplicationRecord
  belongs_to :driver, class_name: 'User', foreign_key: :driver_id
  validates :driver, presence: true

  def occurred_date
    occurred_at.strftime '%A, %B %e'
  end

  def occurred_time
    occurred_at.strftime '%l:%M %P'
  end
end
