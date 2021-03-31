# frozen_string_literal: true

class SupervisorReportsController < ApplicationController
  before_action :set_report, :restrict_to_supervisors
  before_action :build_witnesses, only: :edit

  def history
    @history = @report.versions.order 'created_at desc'
  end

  def update
    if @report.update(report_params) && @incident
      delete_witnesses
      redirect_to @incident,
                  notice: 'Incident report was successfully saved.'
    elsif @incident
      build_witnesses and render 'edit'
    else
      redirect_to incidents_path, notice: 'This incident report no longer exists.'
    end
  end

  private

  def build_witnesses
    @report.witnesses.build unless @report.witnesses.present?
    @report.witnesses
  end

  def delete_witnesses
    report_params[:witnesses_attributes]&.each do |_witness_num, witness_info|
      # only their id is given in params, which means that field was deleted.
      @report.witnesses.destroy(witness_info.values.first) if witness_info.values.length == 1
    end
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
