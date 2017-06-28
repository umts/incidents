# frozen_string_literal: true

class IncidentReportsController < ApplicationController
  # TODO: access control
  before_action :set_report

  def update
    if @report.update(report_params)
      redirect_to @incident,
                  notice: 'Incident report was successfully saved.'
    else render 'incidents/edit'
    end
  end

  private

  def report_params
    params.require(:incident_report).permit!
  end

  def set_report
    @report = IncidentReport.find params.require(:id)
    @incident = @report.incident
  end
end
