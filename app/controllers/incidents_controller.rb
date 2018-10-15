# frozen_string_literal: true

class IncidentsController < ApplicationController
  # set_incident handles access control for member routes.
  before_action :restrict_to_staff, only: %i[destroy incomplete]
  before_action :restrict_to_supervisors, only: :claim
  before_action :set_incident,
    only: %i[claim claims_export destroy edit show update]
  before_action :set_user_lists, only: %i[create new]

  def batch_hastus_export
    @incidents = Incident.where(id: params[:ids])
    send_data render_to_string('batch_export.xml.haml'),
      filename: "#{@incidents.map(&:id).sort.join(',')}.xml",
      disposition: 'attachment'
    @incidents.each(&:mark_as_exported_to_hastus)
  end
  
  def claim
    @incident.claim_for current_user
    redirect_to incidents_path,
                notice: 'You have claimed this incident. Please complete the supervisor report.'
  end

  def claims_export
    result = @incident.export_to_claims!
    case result.fetch(:status)
    when :success
      notice = 'Exported successfully to claims.'
    when :failure
      alert = "Export to claims failed. Reason: #{result.fetch(:reason)}"
    when :invalid
      alert = 'Export to claims failed. ' \
        'Incident had been marked as completed, but is no longer valid. ' \
        'Incident is now marked as incomplete. ' \
        'Please re-mark as completed and fix any errors ' \
        'before attempting another export.'
    end
    redirect_back fallback_location: @incident,
      notice: notice, alert: alert
  end

  def create
    @incident = Incident.new
    @incident.assign_attributes incident_params
    if @incident.save
      @incident.notify_supervisor_of_new_report if @assigning_supervisor
      @incident.remove_supervisor if @removing_supervisor
      redirect_to incidents_path, notice: 'Incident was successfully created.'
    else render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @incident.destroy
    respond_to do |format|
      format.html do
        redirect_to request.referer,
                    notice: 'Incident was successfully deleted.'
      end
      format.json { head :no_content }
    end
  end

  def edit
    deny_access and return if !current_user.staff? && @incident.reviewed?
    @reason_codes = ReasonCode.order(:identifier)
    @supplementary_reason_codes = SupplementaryReasonCode.order(:identifier)
    if current_user.driver?
      # It's the only thing they can edit anyway.
      redirect_to edit_incident_report_path(@incident.driver_incident_report)
    end
  end

  def incomplete
    @incidents = Incident.in_divisions(current_user.divisions).incomplete.occurred_order
    if @incidents.blank?
      redirect_to incidents_path, notice: 'No incomplete incidents.'
    end
  end

  def index
    if current_user.staff?
      parse_dates
      @incidents = Incident.between(@start_date, @end_date)
                           .in_divisions(current_user.divisions)
                           .includes(:driver, :supervisor, :staff_reviews)
                           .occurred_order
      render :by_date and return
    end
    @incidents = if current_user.supervisor?
                   Incident.for_supervisor current_user
                 else Incident.for_driver current_user
                 end
    @incidents = @incidents.incomplete.occurred_order
  end

  def new
    if current_user.driver?
      @incident = Incident.create driver_incident_report_attributes: { user_id: current_user.id }
      redirect_to edit_incident_path(@incident)
    else @incident = Incident.new
    end
  end

  def search
    @incidents = Incident.in_divisions(current_user.divisions).by_claim(params.require :claim_number)
                         .includes(:driver, :supervisor, :staff_reviews)
                         .occurred_order
    render :by_date
  end

  def show
    respond_to do |format|
      format.csv { send_data @incident.to_csv, filename: "#{@incident.id}.csv" }
      format.html { render 'show' }
      format.pdf { record_print_event and render pdf: 'show.pdf.prawn' }
      format.xml do
        unless Rails.env.development?
          response.set_header 'Content-Disposition', 'attachment'
        end
        @incident.mark_as_exported_to_hastus
        render 'show.xml.haml'
      end
    end
  end

  def unclaimed
    @incidents = Incident.in_divisions(current_user.divisions).unclaimed.occurred_order
    if @incidents.blank?
      redirect_to incidents_path, notice: 'No unclaimed incidents.'
    end
  end

  def update
    @reason_codes = ReasonCode.order(:identifier)
    @supplementary_reason_codes = SupplementaryReasonCode.order(:identifier)
    @incident.assign_attributes incident_params
    respond_to do |format|
      if @incident.save
        @incident.notify_supervisor_of_new_report if @assigning_supervisor
        @incident.remove_supervisor if @removing_supervisor
        format.html do
          redirect_to @incident,
                      notice: 'Incident report was successfully saved.'
        end
        format.json { render :show, status: :ok, location: @incident }
      else
        format.html { render :edit }
      end
    end
  end

  private

  def incident_params
    data = params.require(:incident).permit!
    sup_report_attrs = data[:supervisor_incident_report_attributes]
    if sup_report_attrs.present?
      @assigning_supervisor = sup_report_attrs[:user_id].present? &&
                              @incident.supervisor_report.nil?
      @removing_supervisor = sup_report_attrs.key?(:user_id) &&
                             sup_report_attrs[:user_id].blank?
      if @assigning_supervisor
        @incident.supervisor_report = SupervisorReport.new
      elsif @removing_supervisor
        data.delete :supervisor_incident_report_attributes
      end
    end
    data
  end

  # rubocop:disable Style/IfUnlessModifier
  # I don't want to write start_date and end_date differently.
  def parse_dates
    @mode = params[:mode] || 'month'
    if params[:start_date].present?
      @start_date = Time.zone.parse params[:start_date]
    end
    if @mode == 'week'
      @start_date ||= Time.zone.now.beginning_of_week(:sunday)
      @end_date = @start_date.end_of_week(:sunday)
      @prev_start = @start_date - 1.week
    else
      @start_date ||= Time.zone.now.beginning_of_month
      @week_start_date = @start_date.beginning_of_week(:sunday)
      @prev_start = @start_date - 1.month
      @end_date = @start_date.end_of_month
    end
    @next_start = @end_date + 1.day
  end
  # rubocop:enable Style/IfUnlessModifier

  def set_user_lists
    @drivers = User.active.in_divisions(current_user.divisions).name_order
    @supervisors = User.active.supervisors.in_divisions(current_user.divisions).name_order
  end

  def record_print_event
    reports = [@incident.driver_incident_report]
    unless current_user == @incident.driver
     reports += [@incident.supervisor_incident_report, @incident.supervisor_report]
    end
    reports.compact.each do |report|
      report.versions.create! event: 'print', whodunnit: current_user.id
    end
  end

  def set_incident
    @incident = Incident.find(params[:id])
    @staff_reviews = @incident.staff_reviews.order :created_at
    return if current_user.staff?
    # if incident has a supervisor, deny_access and return
    unless [@incident.driver, @incident.supervisor].include? current_user
      deny_access and return
    end
  end
end
