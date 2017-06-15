# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail

  has_many :incident_reports, dependent: :restrict_with_error
  has_many :supervisor_reports, dependent: :restrict_with_error

  devise :database_authenticatable, :validatable
  validates :name, :email, presence: true, uniqueness: true
  validates :badge_number, presence: true, unless: :staff?

  scope :active, -> { where active: true }
  scope :inactive, -> { where.not active: true }
  scope :drivers, -> { where staff: false }
  scope :staff, -> { where staff: true }
end
