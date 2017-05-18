# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, only: %i[destroy edit incidents update]
  before_action :access_control

  def destroy
    @user.destroy!
    flash[:notice] = 'User was deleted.'
    redirect_to users_path
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:notice] = 'User was created.'
      redirect_to users_path
    else
      flash[:errors] = @user.errors.full_messages
      render 'edit'
    end
  end

  def incidents
    @incidents = @user.incidents.order :occurred_at
  end

  def index
    @users = User.includes :incidents
  end

  def update
    @user.assign_attributes user_params
    if @user.save
      flash[:notice] = 'User was updated.'
      redirect_to users_path
    else
      flash[:errors] = @user.errors.full_messages
      render 'edit'
    end
  end

  private

  def find_user
    @user = User.find_by id: params.require(:id)
    render nothing: true, status: :not_found and return unless @user.present?
  end

  def user_params
    attrs = params.require(:user).permit!
    if attrs[:password].blank?
      attrs.delete :password
      attrs.delete :password_confirmation
    end
    attrs
  end
end
