# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail


  has_many :incident_reports, dependent: :restrict_with_error
  has_and_belongs_to_many :divisions

  validates :first_name, :last_name, :hastus_id, :divisions, presence: true
  validates :hastus_id, uniqueness: true
  # validates :badge_number, presence: true, if: :driver?

  scope :active, -> { where active: true }
  scope :inactive, -> { where.not active: true }
  scope :drivers, -> { where supervisor: false, staff: false }
  scope :supervisors, -> { where supervisor: true }
  scope :staff, -> { where staff: true }
  scope :with_email, -> { where.not email: nil }

  scope :name_order, -> { order :last_name, :first_name }

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

  def proper_name
    [last_name, first_name].join ', '
  end

  def self.import_from_xml(xml)
    statuses = Hash.new(0)
    users_present = []
    xml.css('User').each do |user_data|
      hastus_id = user_data.at_css('hastus_id').text
      attrs = {}
      attrs[:first_name] = user_data.at_css('first_name').text.capitalize
      attrs[:last_name] = user_data.at_css('last_name').text.capitalize
      attrs[:division] = user_data.at_css('division').text
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
        end
      else
        user = User.new attrs.merge(hastus_id: hastus_id)
        if user.valid?
          user.save!
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

  def deactivate
    update active: false
  end
end
