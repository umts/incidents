# frozen_string_literal: true

class SupervisorReportsController < ApplicationController
  before_action :set_report, :restrict_to_supervisors
  before_action :build_witnesses, only: :edit

  def history
    @history = @report.versions.order 'created_at desc'
  end

  def update
    if @incident
      if @report.update report_params
        redirect_to @incident,
                    notice: 'Incident report was successfully saved.'
      else build_witnesses and render 'edit'
      end
    else
      redirect_to incidents_url, notice: 'This incident report no longer exists.'
    end
  end

  private

  def build_witnesses
    @report.witnesses.build unless @report.witnesses.present?
    @report.witnesses
  end

  def report_params
    data = params.require(:supervisor_report).permit!
    unless data[:witness_info] == '1'
      data.delete :witnesses_attributes
      @report.witnesses.destroy_all
    end
    data.except :witness_info
  end

  def set_report
    @report = SupervisorReport.find params.require(:id)
    @incident = @report.incident
  end
end
