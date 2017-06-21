# frozen_string_literal: true

class IncidentReportsController < ApplicationController
  # TODO access control
  before_action :set_report, only: %i[edit update]

  def update
    respond_to do |format|
      if @report.update(report_params)
        format.html do
          redirect_to @incident,
                      notice: 'Incident report was successfully saved.'
        end
        format.json { render :show, status: :ok, location: @incident }
      else
        format.html { render 'incidents/edit' }
        format.json do
          render json: @report.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def report_params
    params.require(:incident_report).permit!
  end

  def set_report
    @report = IncidentReport.find(params[:id])
    @incident = @report.incident
  end
end
