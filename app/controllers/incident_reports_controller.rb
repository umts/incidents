# frozen_string_literal: true

class IncidentReportsController < ApplicationController
  # TODO access control
  before_action :set_report, only: %i[edit]

  private

  def set_report
    @report = IncidentReport.find(params[:id])
  end
end
