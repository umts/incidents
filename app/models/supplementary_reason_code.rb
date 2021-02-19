# frozen_string_literal: true

class SupplementaryReasonCode < ApplicationRecord
  has_many :incidents
  validates :identifier, :description, presence: true
  validates :identifier, uniqueness: { case_sensitive: false }

  def full_label
    [identifier, description].join ': '
  end
end
