FactoryGirl.define do
  factory :staff_review do
    user { create :user, :staff }
    incident
    text 'Review'
  end
end
