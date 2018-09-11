# frozen_string_literal: true

class IncidentReportsController < ApplicationController
  # set_report handles access control for member routes.
  before_action :set_report
  before_action :build_passengers, only: :edit

  def history
    @history = @report.versions.order 'created_at desc'
  end

  def update
    if @incident
      if @report.update(report_params)
        if @current_user == @incident.supervisor && @incident.supervisor_report.invalid?
          redirect_to edit_supervisor_report_path(@incident.supervisor_report),
            notice: 'Incident report was successfully saved. Please complete the supervisor report.'
        elsif @current_user == @incident.driver
          redirect_to incident_path(@incident, format: :pdf)
        else redirect_to @incident, notice: 'Incident report was successfully saved.'
        end
      else build_passengers and render 'edit'
      end
    else
      redirect_to incidents_path, notice: 'This incident report no longer exists.'
    end
  end

  private

  def build_passengers
    @report.injured_passengers.build unless @report.injured_passengers.present?
    @report.injured_passengers
  end

  def report_params
    data = params.require(:incident_report).permit!
    unless data[:inj_pax_info] == '1'
      data.delete :injured_passengers_attributes
      @report.injured_passengers.destroy_all
    end
    data.except :inj_pax_info
  end

  def set_report
    @report = IncidentReport.find params.require(:id)
    @incident = @report.incident
    return if current_user.staff?
    deny_access and return unless @report.user == current_user
  end
end
