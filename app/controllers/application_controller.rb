# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :check_for_incomplete_incidents, if: -> { user_signed_in? }
  before_action :check_for_unclaimed_incidents, if: -> { user_signed_in? }

  private

  def check_for_incomplete_incidents
    @incomplete_incidents = Incident.in_divisions(current_user.divisions).incomplete
  end

  def check_for_unclaimed_incidents
    @unclaimed_incidents = Incident.in_divisions(current_user.divisions).unclaimed
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

  def restrict_to_staff
    deny_access and return unless current_user.staff?
  end

  def restrict_to_supervisors
    unless current_user.supervisor? || current_user.staff?
      deny_access and return
    end
  end
end
