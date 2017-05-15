class Incident < ApplicationRecord
  belongs_to :driver, class_name: 'User', foreign_key: :driver_id
  validates :driver, presence: true

  def occurred_at_readable
    occurred_at.strftime '%A, %B %e, %l:%M %P'
  end
end
