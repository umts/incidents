# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail

  DIVISIONS = %w[NOHO SPFLD SMECH].freeze

  has_many :incident_reports, dependent: :restrict_with_error

  validates :first_name, :last_name, :hastus_id, :division, presence: true
  validates :hastus_id, uniqueness: true
  # validates :badge_number, presence: true, if: :driver?

  scope :active, -> { where active: true }
  scope :inactive, -> { where.not active: true }
  scope :drivers, -> { where supervisor: false, staff: false }
  scope :supervisors, -> { where supervisor: true }
  scope :staff, -> { where staff: true }
  scope :with_email, -> { where.not email: nil }

  scope :name_order, -> { order :last_name, :first_name }

  def driver?
    !(supervisor? || staff?)
  end

  def full_name
    [first_name, last_name].join ' '
  end

  def group
    if driver? then 'Drivers'
    elsif supervisor? then 'Supervisors'
    else 'Staff'
    end
  end

  def proper_name
    [last_name, first_name].join ', '
  end
end
