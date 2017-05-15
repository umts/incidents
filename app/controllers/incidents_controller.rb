class IncidentsController < ApplicationController
  before_action :access_control, only: %i[new destroy]
  before_action :set_incident, only: [:show, :edit, :update, :destroy]
  before_action :driver_list, only: %i[edit new]

  # GET /incidents
  # GET /incidents.json
  def index
    @incidents = if current_user.staff?
                   Incident.order :occurred_at
                 else current_user.incidents.order :occurred_at
                 end
  end

  # GET /incidents/1
  # GET /incidents/1.json
  def show
  end

  # GET /incidents/new
  def new
    @incident = Incident.new
  end

  # GET /incidents/1/edit
  def edit
  end

  # POST /incidents
  # POST /incidents.json
  def create
    @incident = Incident.new(incident_params)

    respond_to do |format|
      if @incident.save
        format.html { redirect_to @incident, notice: 'Incident was successfully created.' }
        format.json { render :show, status: :created, location: @incident }
      else
        format.html { render :new }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /incidents/1
  # PATCH/PUT /incidents/1.json
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

  # DELETE /incidents/1
  # DELETE /incidents/1.json
  def destroy
    @incident.destroy
    respond_to do |format|
      format.html { redirect_to incidents_url, notice: 'Incident was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def driver_list
    @drivers = User.drivers.order :name
  end

  def set_incident
    @incident = Incident.find(params[:id])
    if @incident.driver != current_user && !current_user.staff?
      deny_access and return
    end
  end

  def incident_params
    params.require(:incident).permit(:driver, :occurred_at, :shift, :route, :vehicle, :location, :action_before, :action_during, :weather_conditions, :light_conditions, :road_conditions, :camera_used, :injuries, :damage, :description)
  end
end
