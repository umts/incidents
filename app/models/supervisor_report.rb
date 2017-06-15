class SupervisorReport < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :incident
end
