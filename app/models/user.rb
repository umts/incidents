class User < ApplicationRecord
  has_many :incidents, foreign_key: :driver_id

  devise :database_authenticatable, :validatable
  validates :name, :email, presence: true, uniqueness: true

  scope :drivers, -> { where staff: false }
  scope :staff, -> { where staff: true }
end
