class ReasonCode < ApplicationRecord
  has_many :incidents
  validates :identifier, :description, presence: true, uniqueness: true
end
