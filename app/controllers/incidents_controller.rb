# frozen_string_literal: true

class IncidentsController < ApplicationController
  # set_incident handles access control for member routes.
  before_action :restrict_to_staff, only: %i[destroy incomplete]
  before_action :restrict_to_supervisors, only: :claim
  before_action :set_incident, only: %i[destroy edit show update]
  before_action :set_user_lists, only: %i[create new]

  def batch_export
    @incidents = Incident.where(id: params[:ids])
    send_data render_to_string('batch_export.xml.haml'),
      filename: "#{@incidents.map(&:id).sort.join(',')}.xml",
      disposition: 'attachment'
    @incidents.each(&:mark_as_exported)
  end
  
  def claim
    @incident = Incident.find(params[:id])
    @incident.claim_for current_user
    redirect_to incidents_url,
                notice: 'You have claimed this incident. Please complete the supervisor report.'
  end

  def create
    @incident = Incident.new
    @incident.assign_attributes incident_params
    if @incident.save
      @incident.notify_supervisor_of_new_report if @assigning_supervisor
      @incident.remove_supervisor if @removing_supervisor
      redirect_to incidents_url, notice: 'Incident was successfully created.'
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
    if current_user.driver?
      # It's the only thing they can edit anyway.
      redirect_to edit_incident_report_url(@incident.driver_incident_report)
    end
    s_report = @incident.supervisor_report
    if s_report.present?
      [s_report.witnesses, s_report.injured_passengers].each do |collection|
        collection.build if collection.blank?
      end
    end
  end

  def incomplete
    @incidents = Incident.in_divisions(current_user.divisions).incomplete.occurred_order
    if @incidents.blank?
      redirect_to incidents_url, notice: 'No incomplete incidents.'
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
      redirect_to edit_incident_url(@incident)
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
        @incident.mark_as_exported
        render 'show.xml.haml'
      end
    end
  end

  def unclaimed
    @incidents = Incident.in_divisions(current_user.divisions).unclaimed.occurred_order
    if @incidents.blank?
      redirect_to incidents_url, notice: 'No unclaimed incidents.'
    end
  end

  def update
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
      if sup_report_attrs[:user_id].present?
        @incident.supervisor_report = SupervisorReport.new
        @assigning_supervisor = true
      elsif sup_report_attrs.key? :user_id # but it's blank anyway
        data.delete :supervisor_incident_report_attributes
        @removing_supervisor = true
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
    unless [@incident.driver, @incident.supervisor].include? current_user
      deny_access and return
    end
  end
end
