class IncidentsController < ApplicationController
  before_action :access_control, only: %i[destroy incomplete new]
  before_action :set_incident, only: %i[destroy edit show update]

  def create
    @incident = Incident.new(incident_params)
    respond_to do |format|
      if @incident.save
        format.html { redirect_to incidents_url, notice: 'Incident was successfully created.' }
        format.json { render :show, status: :created, location: @incident }
      else
        format.html { render :new }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @incident.destroy
    respond_to do |format|
      format.html { redirect_to incidents_url, notice: 'Incident was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def incomplete
    @incidents = Incident.incomplete.order :occurred_at
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
  end

  def update
    respond_to do |format|
      if @incident.update(incident_params)
        format.html { redirect_to @incident, notice: 'Incident was successfully updated.' }
        format.json { render :show, status: :ok, location: @incident }
      else
        format.html { render :edit }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def incident_params
    params.require(:incident).permit :driver_id, :occurred_at, :shift, :route,
      :vehicle, :location, :action_before, :action_during, :weather_conditions,
      :light_conditions, :road_conditions, :camera_used, :injuries, :damage,
      :description, :completed
  end

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
      @prev_start = @start_date - 1.month
      @end_date ||= @start_date.end_of_month
    end
    @next_start = @end_date + 1.day
  end

  def set_incident
    @incident = Incident.find(params[:id])
    if @incident.driver != current_user && !current_user.staff?
      deny_access and return
    end
  end
end
