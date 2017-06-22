# frozen_string_literal: true

class ApplicationController < ActionController::Base
  attr_reader :current_user

  protect_from_forgery with: :exception
  before_action :set_current_user
  before_action :check_for_incomplete_incidents

  private

  def access_control
    deny_access and return unless @current_user.staff?
  end

  def check_for_incomplete_incidents
    @incomplete_incidents = Incident.incomplete
    @unreviewed_incidents = Incident.unreviewed
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

  def set_current_user
    if session.key? :user_id
      @current_user = User.find_by id: session[:user_id]
      PaperTrail.whodunnit = @current_user.id
    end
    unless @current_user.present?
      session[:requested_path] = request.path
      redirect_to login_path
    end
  end
end
