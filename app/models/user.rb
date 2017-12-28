# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail
  devise :database_authenticatable, :recoverable, :registerable

  has_many :incident_reports, dependent: :restrict_with_error
  has_many :divisions_users
  has_many :divisions, through: :divisions_users

  validates :first_name, :last_name, :badge_number, :divisions, presence: true
  validates :badge_number, uniqueness: true
  validates :password, :password_confirmation, presence: true

  scope :active, -> { where active: true }
  scope :inactive, -> { where.not active: true }
  scope :drivers, -> { where supervisor: false, staff: false }
  scope :supervisors, -> { where supervisor: true }
  scope :staff, -> { where staff: true }
  scope :with_email, -> { where.not email: nil }

  scope :name_order, -> { order :last_name, :first_name }
  scope :in_divisions, (lambda do |divisions|
    joins(:divisions_users).where(divisions_users: { division_id: divisions.pluck(:id) })
  end)

  before_validation :set_default_password, if: :new_record?
  before_save :track_password_changed

  # Only active users should be able to log in.
  def active_for_authentication?
    super && active?
  end

  def deactivate
    update active: false
  end

  def division
    divisions.first
  end

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

  def hastus_id
    badge_number
  end

  def inactive_message
    if !active? then :inactive
    else super
    end
  end

  def proper_name
    [last_name, first_name].join ', '
  end

  def requires_password_change?
    !(driver? || password_changed_from_default?)
  end

  def set_default_password
    assign_attributes password: last_name,
      password_confirmation: last_name,
      password_changed_from_default: false
  end

  def self.import_from_xml(xml)
    statuses = Hash.new(0)
    users_present = []
    xml.css('User').each do |user_data|
      hastus_id = user_data.at_css('hastus_id').text
      attrs = {}
      attrs[:first_name] = user_data.at_css('first_name').text.capitalize
      attrs[:last_name] = user_data.at_css('last_name').text.capitalize
      job_class = user_data.at_css('job_class').text
      attrs[:supervisor] = job_class == 'Supervisor'
      user = User.find_by hastus_id: hastus_id
      if user.present?
        user.assign_attributes attrs
        if user.changed?
          if user.valid?
            user.save!
            users_present << user
            statuses[:updated] += 1
          else statuses[:rejected] += 1
          end
        else users_present << user
        end
      else
        # Only assign divisions to new users.
        division_name = user_data.at_css('division').text.upcase
        attrs[:divisions] = [Division.where(name: division_name).first_or_create]
        user = User.new attrs.merge(hastus_id: hastus_id)
        if user.save
          users_present << user
          statuses[:imported] += 1
        else statuses[:rejected] += 1
        end
      end
    end
    # Don't deactivate staff automatically, since they're not always
    # in Hastus.
    inactive_users = User.active - User.staff - users_present
    inactive_users.each(&:deactivate)
    statuses[:deactivated] = inactive_users.count
    statuses
  end

  private

  def track_password_changed
    if encrypted_password_changed?
      assign_attributes password_changed_from_default: true
    end
  end
end
