class StaffReview < ApplicationRecord
  belongs_to :incident
  belongs_to :user
  validates :incident, :user, :text, presence: true
  validate :user_is_staff

  def timestamp
    created_at.strftime '%A, %B %e %l:%M %P'
  end

  private

  def user_is_staff
    unless user.staff?
      errors.add :user, 'must be a staff member'
    end
  end
end
