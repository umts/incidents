class StaffReview < ApplicationRecord
  belongs_to :incident
  belongs_to :user
  validates :incident, :user, :text, presence: true
  validates :user, inclusion: { in: User.staff }
end
