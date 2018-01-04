# frozen_string_literal: true

class StaffReviewsController < ApplicationController
  before_action :restrict_to_staff
  before_action :set_staff_review, except: :create

  def create
    staff_review_params = params.require(:staff_review)
                                .permit(:incident_id, :text)
                                .merge(user: current_user)
    @staff_review = StaffReview.create! staff_review_params
    redirect_to @staff_review.incident, notice: 'Review successfully submitted.'
  end

  def destroy
    @staff_review.destroy
    redirect_to @staff_review.incident, notice: 'Review successfully removed.'
  end

  def update
    @staff_review.update! params.require(:staff_review).permit :text
    redirect_to @staff_review.incident, notice: 'Review successfully updated.'
  end

  private

  def set_staff_review
    @staff_review = StaffReview.find params.require(:id)
  end
end
