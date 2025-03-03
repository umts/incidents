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
    data = params.require(:supervisor_report).permit(:pictures_saved, :saved_pictures, :passenger_statement, :faxed,
                                                     :witness_info, :test_status, :amplifying_comments,
                                                     :test_due_to_bodily_injury, :test_due_to_disabling_damage,
                                                     :test_due_to_fatality, :completed_drug_test,
                                                     :completed_alcohol_test, :observation_made_at,
                                                     :test_due_to_employee_appearance, :employee_appearance,
                                                     :test_due_to_employee_behavior, :employee_behavior,
                                                     :test_due_to_employee_speech, :employee_speech,
                                                     :test_due_to_employee_odor, :employee_odor, :testing_facility,
                                                     :testing_facility_notified_at,
                                                     :employee_representative_notified_at,
                                                     :employee_representative_arrived_at, :employee_notified_of_test_at,
                                                     :employee_departed_to_test_at, :employee_arrived_at_test_at,
                                                     :test_started_at, :test_ended_at,
                                                     :employee_returned_to_work_or_released_from_duty_at,
                                                     :superintendent_notified_at, :program_manager_notified_at,
                                                     :director_notified_at,
                                                     witnesses_attributes: %i[id onboard_bus name address
                                                                              home_phone cell_phone work_phone])
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
