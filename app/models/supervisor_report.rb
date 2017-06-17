class SupervisorReport < ApplicationRecord
  has_paper_trail

  belongs_to :user
  validates :user, inclusion: { in: ->(_) { User.supervisors } }
  has_one :incident
end
