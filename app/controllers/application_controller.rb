# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  before_action :check_for_required_password_change, if: -> { user_signed_in? }
  before_action :check_for_incomplete_incidents, if: -> { user_signed_in? }
  before_action :check_for_unclaimed_incidents, if: -> { user_signed_in? }

  private

  def check_for_incomplete_incidents
    @incomplete_incidents = Incident.in_divisions(current_user.divisions).incomplete
  end

  def check_for_required_password_change
    return if devise_controller? || !current_user.requires_password_change?

    redirect_to change_password_path,
                notice: 'You must change your password from the default before continuing.'
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
    deny_access and return unless current_user.supervisor? || current_user.staff?
  end
end
