# frozen_string_literal: true

class Division < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :claims_id, presence: true
  has_many :divisions_users
  has_many :users, through: :divisions_users
end
