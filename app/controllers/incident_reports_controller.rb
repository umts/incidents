# frozen_string_literal: true

class IncidentReportsController < ApplicationController
  # set_report handles access control for member routes.
  before_action :set_report

  def history
    @history = @report.versions.order 'created_at desc'
  end

  def update
    if @report.update(report_params)
      redirect_to @incident, notice: 'Incident report was successfully saved.'
    else render 'edit'
    end
  end

  private

  def report_params
    params.require(:incident_report).permit!
  end

  def set_report
    @report = IncidentReport.find params.require(:id)
    @incident = @report.incident
    return if current_user.staff?
    deny_access and return unless @report.user == current_user
  end
end
