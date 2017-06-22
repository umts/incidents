# frozen_string_literal: true

class ApplicationController < ActionController::Base
  attr_reader :current_user

  protect_from_forgery with: :exception
  before_action :set_current_user
  before_action :set_paper_trail_whodunnit
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
    end
    redirect_to login_path unless @current_user.present?
  end
end
