# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, except: %i[create new index]

  before_action :access_control

  def deactivate
    @user.update! active: false
    flash[:notice] = 'Driver was deactivated successfully.'
    redirect_to users_path
  end

  def destroy
    if @user.destroy
      flash[:notice] = 'Driver was deleted successfully.'
    else
      flash[:alert] = 'Cannot delete drivers who have incidents in their name.'
    end
    redirect_to users_path
  end

  def create
    @user = User.new user_params
    attempt_save
  end

  def incidents
    @incidents = @user.incidents.order :occurred_at
  end

  def index
    @inactive = params[:inactive] == 'true'
    @users = if @inactive
               User.inactive
             else User.active
             end
    @users = @users.includes(:incident_reports).name_order
  end

  def reactivate
    @user.update! active: true
    flash[:notice] = 'Driver was reactivated successfully.'
    redirect_to users_path
  end

  def update
    @user.assign_attributes user_params
    attempt_save
  end

  private

  def attempt_save
    if @user.save
      flash[:notice] = "Driver was #{params[:action]}d successfully."
      redirect_to users_path
    else
      flash[:errors] = @user.errors.full_messages
      render 'edit'
    end
  end

  def find_user
    @user = User.find_by id: params.require(:id)
    render nothing: true, status: :not_found and return unless @user.present?
  end

  def user_params
    attrs = params.require(:user).permit :first_name, :last_name,
      :badge_number, :supervisor, :staff, :hastus_id, :division
    if attrs[:password].blank?
      attrs.delete :password
      attrs.delete :password_confirmation
    end
    attrs
  end
end
