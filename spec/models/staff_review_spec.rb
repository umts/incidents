require 'spec_helper'

describe StaffReview do
  describe 'validations' do
    context 'user is not staff' do
      it 'is not valid' do
        driver = create :user, :driver
        review = build :staff_review, user: driver
        expect(review).not_to be_valid
      end
    end
  end
end
