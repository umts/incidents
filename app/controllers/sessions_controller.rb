class SessionsController < ApplicationController
  skip_before_action :set_current_user

  def destroy
    session.clear
    redirect_to root_path
  end

  def login
    if request.get?
      session[:requested_path] = request.referer
      define_users unless Rails.env.production?
    else
      if authenticate_user
        redirect_to session[:requested_path] || root_path
      else redirect_to login_path, alert: 'Invalid credentials.'
      end
    end
  end

  private

  def authenticate_user
    if Rails.env.production?
      # TODO
    else
      user_id = params.values_at(:staff, :supervisor, :driver).find(&:present?)
      if User.find_by id: user_id
        session[:user_id] = user_id and return true
      end
    end
  end

  def define_users
    @staff = User.staff.name_order
    @supervisors = User.supervisors.name_order
    @drivers = User.drivers.name_order
  end
end
