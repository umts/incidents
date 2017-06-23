# frozen_string_literal: true

class IncidentsController < ApplicationController
  # set_incident handles access control for member routes.
  before_action :access_control, only: %i[destroy incomplete]
  before_action :restrict_to_supervisors, only: %i[create new]
  before_action :set_incident, only: %i[destroy edit history show update]

  def create
    @incident = Incident.new incident_params
    supervisor_id = incident_params[:supervisor_incident_report_attributes][:user_id]
    @incident.supervisor_report = SupervisorReport.new user_id: supervisor_id
    if @incident.save
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
    deny_access and return if !@current_user.staff? && @incident.reviewed?
  end

  def history
    @history = @incident.versions.order 'created_at desc'
  end

  def incomplete
    @incidents = Incident.incomplete.order :occurred_at
    if @incidents.blank?
      redirect_to incidents_url, notice: 'No incomplete incidents.'
    end
  end

  def index
    if @current_user.staff?
      parse_dates
      @incidents = Incident.between(@start_date, @end_date).order :occurred_at
      render :by_date and return
    end
    if @current_user.supervisor?
      @incidents = Incident.for_supervisor @current_user
    else @incidents = Incident.for_driver @current_user
    end
    @incidents = @incidents.incomplete.order :occurred_at
  end

  def new
    @incident = Incident.new
  end

  def show
    respond_to do |format|
      format.pdf { render pdf: 'show.pdf.prawn' }
      format.html { render 'show' }
    end
  end

  def unreviewed
    @incidents = Incident.unreviewed.order :occurred_at
    if @incidents.blank?
      redirect_to incidents_url, notice: 'No unreviewed incidents.'
    end
  end

  def update
    respond_to do |format|
      if @incident.update(incident_params)
        format.html do
          redirect_to @incident,
                      notice: 'Incident report was successfully saved.'
        end
        format.json { render :show, status: :ok, location: @incident }
      else
        format.html { render :edit }
        format.json do
          render json: @incident.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def incident_params
    params.require(:incident).permit!
  end

  # rubocop:disable Style/IfUnlessModifier
  # I don't want to write start_date and end_date differently.
  def parse_dates
    @mode = params[:mode] || 'month'
    if params[:start_date].present?
      @start_date = Time.zone.parse params[:start_date]
    end
    if params[:end_date].present?
      @end_date = Time.zone.parse params[:end_date]
    end
    if @mode == 'week'
      @start_date ||= Time.zone.now.beginning_of_week(:sunday)
      @end_date ||= @start_date.end_of_week(:sunday)
      @prev_start = @start_date - 1.week
    else
      @start_date ||= Time.zone.now.beginning_of_month
      @week_start_date = @start_date.beginning_of_week(:sunday)
      @prev_start = @start_date - 1.month
      @end_date ||= @start_date.end_of_month
    end
    @next_start = @end_date + 1.day
  end
  # rubocop:enable Style/IfUnlessModifier

  def set_incident
    @incident = Incident.find(params[:id])
    @staff_reviews = @incident.staff_reviews.order :created_at
    return if @current_user.staff?
    unless [@incident.driver, @incident.supervisor].include? @current_user
      deny_access and return
    end
  end
end
