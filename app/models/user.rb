# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail

  has_many :incident_reports, dependent: :restrict_with_error
  has_many :supervisor_reports, dependent: :restrict_with_error

  validates :name, :hastus_id, presence: true
  validates :hastus_id, uniqueness: true
  # validates :badge_number, presence: true, if: :driver?

  scope :active, -> { where active: true }
  scope :inactive, -> { where.not active: true }
  scope :drivers, -> { where supervisor: false, staff: false }
  scope :supervisors, -> { where supervisor: true } # TODO
  scope :staff, -> { where staff: true }

  def driver?
    !(supervisor? || staff?)
  end
end
