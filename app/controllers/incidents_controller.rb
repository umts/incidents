# frozen_string_literal: true

class IncidentsController < ApplicationController
  before_action :access_control, only: %i[destroy incomplete new]
  before_action :set_incident, only: %i[destroy edit show update]

  def create
    Incident.create incident_params
    redirect_to incidents_url, notice: 'Incident was successfully created.'
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
  end

  def incomplete
    @incidents = Incident.incomplete.order :occurred_at
    if @incidents.blank?
      redirect_to incidents_url, notice: 'No incomplete incidents.'
    end
  end

  def index
    if current_user.staff?
      parse_dates
      @incidents = Incident.between(@start_date, @end_date).order :occurred_at
      render :by_date and return
    end
    @incidents = current_user.incidents.order :occurred_at
  end

  def new
    @incident = Incident.new
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
                      notice: 'Incident was successfully updated.'
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
    params.require(:incident).permit :driver_id, :occurred_at, :shift, :route,
                                     :vehicle, :location, :action_before,
                                     :action_during, :weather_conditions,
                                     :light_conditions, :road_conditions,
                                     :camera_used, :injuries, :damage,
                                     :description, :completed
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
    if @incident.driver != current_user && !current_user.staff?
      deny_access and return
    end
  end
end
