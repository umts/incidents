# frozen_string_literal: true

class SupervisorReportsController < ApplicationController
  before_action :set_report, :restrict_to_supervisors

  def history
    @history = @report.versions.order 'created_at desc'
  end

  def update
    if @report.update report_params
      redirect_to @incident,
                  notice: 'Incident report was successfully saved.'
    else render 'incidents/edit'
    end
  end

  private

  def report_params
    params.require(:supervisor_report).permit!
  end

  def set_report
    @report = SupervisorReport.find params.require(:id)
    @incident = @report.incident
  end
end
