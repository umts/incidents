# frozen_string_literal: true

class Division < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :users
end
