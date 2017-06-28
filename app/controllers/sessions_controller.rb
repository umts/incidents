# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :set_current_user

  def destroy
    session.clear
    redirect_to root_path
  end

  def login
    if request.get?
      define_users unless Rails.env.production?
    elsif authenticate_user
      redirect_to session[:requested_path] || root_path
      session.delete :requested_path
    else redirect_to login_path, alert: 'Invalid credentials.'
    end
  end

  private

  def authenticate_user
    if !Rails.env.production?
      user_id = params.values_at(:staff, :supervisor, :driver).find(&:present?)
      user = User.find_by id: user_id
    end
    user ||= User.find_by badge_number: params.require(:badge_number),
                          last_name: params.require(:last_name)
    session[:user_id] = user.id if user.present?
    return user.present?
  end

  def define_users
    @staff = User.staff.name_order
    @supervisors = User.supervisors.name_order
    @drivers = User.drivers.name_order
  end
end
