class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private

  def access_control
    deny_access and return unless current_user.staff?
  end

  def deny_access
    if request.xhr?
      head :unauthorized
    else
      render file: 'public/401.html',
             status: :unauthorized,
             layout: false
    end
  end
end
