# frozen_string_literal: true

class ReasonCode < ApplicationRecord
  has_many :incidents
  validates :identifier, :description, presence: true, uniqueness: true

  def full_label
    [identifier, description].join ': '
  end
end
