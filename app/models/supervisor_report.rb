class SupervisorReport < ApplicationRecord
  has_paper_trail

  REASONS_FOR_TEST = ['Post-Accident', 'Reasonable Suspicion']
  TESTING_FACILITIES = [
    'Occuhealth East Longmeadow',
    'Occuhealth Northampton',
    'On-Site (Employee Work Location)'
  ]

  belongs_to :user
  validates :user, inclusion: { in: ->(_) { User.supervisors } }
  validates :reason_test_completed, inclusion: { in: REASONS_FOR_TEST }
  has_one :incident
end
