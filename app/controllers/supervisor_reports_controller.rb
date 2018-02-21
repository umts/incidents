# frozen_string_literal: true

class SupervisorReportsController < ApplicationController
  before_action :set_report, :restrict_to_supervisors
  before_action :build_collections, only: :edit

  def history
    @history = @report.versions.order 'created_at desc'
  end

  def update
    if @report.update report_params
      redirect_to @incident,
                  notice: 'Incident report was successfully saved.'
    else build_collections and render 'edit'
    end
  end

  private

  def build_collections
    @report.witnesses.build unless @report.witnesses.present?
    @report.injured_passengers.build unless @report.injured_passengers.present?
  end

  def report_params
    data = params.require(:supervisor_report).permit!
    unless data[:witness_info] == '1'
      data.delete :witnesses_attributes
      @report.witnesses.destroy_all
    end
    unless data[:inj_pax_info] == '1'
      data.delete :injured_passengers_attributes
      @report.injured_passengers.destroy_all
    end
    data.except :witness_info, :inj_pax_info
  end

  def set_report
    @report = SupervisorReport.find params.require(:id)
    @incident = @report.incident
  end
end
