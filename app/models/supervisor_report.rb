class SupervisorReport < ApplicationRecord
  has_paper_trail

  belongs_to :user
  has_one :incident
end
