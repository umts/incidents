# frozen_string_literal: true

class IncidentReportsController < ApplicationController
  # set_report handles access control for member routes.
  before_action :set_report
  before_action :build_passengers, only: :edit

  def history
    @history = @report.versions.order 'created_at desc'
  end

  def update
    if @incident
      if @report.update(report_params)
        delete_passengers
        if @current_user == @incident.supervisor && @incident.supervisor_report.invalid?
          redirect_to edit_supervisor_report_path(@incident.supervisor_report),
                      notice: 'Incident report was successfully saved. Please complete the supervisor report.'
        elsif @current_user == @incident.driver
          redirect_to incident_path(@incident, format: :pdf)
        else redirect_to @incident, notice: 'Incident report was successfully saved.'
        end
      else build_passengers and render 'edit'
      end
    else
      redirect_to incidents_path, notice: 'This incident report no longer exists.'
    end
  end

  private

  def build_passengers
    @report.injured_passengers.build unless @report.injured_passengers.present?
    @report.injured_passengers
  end

  def delete_passengers
    report_params[:injured_passengers_attributes]&.each do |_pax_num, pax_info|
      # only their id is given, which means that they were deleted.
      @report.injured_passengers.destroy(pax_info.values.first) if pax_info.values.length == 1
    end
  end

  def report_params
    data = params.require(:incident_report).permit(:user_id, :occurred_at, :run, :block, :route, :bus,
                                                   :passengers_onboard, :pvta_passenger_information_taken,
                                                   :courtesy_cards_distributed, :courtesy_cards_collected, :speed,
                                                   { incidents: %i[latitude longitude] }, :location, :direction, :town,
                                                   :state, :zip, :weather_conditions, :road_conditions,
                                                   :light_conditions, :headlights_used, :police_on_scene,
                                                   :police_badge_number, :police_town_or_state, :police_case_assigned,
                                                   :ambulance_present, :wheelchair_involved, :vehicle_distance,
                                                   :incident_involved_a_van, :assistance_requested, :chair_on_lift,
                                                   :lift_deployed, :posted_speed_limit, :surface_type, :surface_grade,
                                                   :credentials_exchanged, :summons_or_warning_issued,
                                                   :summons_or_warning_info, :motor_vehicle_collision,
                                                   :other_vehicle_plate, :other_vehicle_state, :other_vehicle_make,
                                                   :other_vehicle_model, :other_vehicle_year, :other_vehicle_color,
                                                   :other_vehicle_passengers, :other_passenger_information_taken,
                                                   :other_vehicle_direction, :other_driver_name,
                                                   :other_driver_license_number, :other_driver_license_state,
                                                   :other_vehicle_driver_address, :other_vehicle_driver_address_town,
                                                   :other_vehicle_driver_address_state,
                                                   :other_vehicle_driver_address_zip, :other_vehicle_driver_home_phone,
                                                   :other_vehicle_driver_cell_phone, :other_vehicle_driver_work_phone,
                                                   :other_vehicle_owned_by_other_driver, :other_vehicle_owner_name,
                                                   :other_vehicle_owner_address, :other_vehicle_owner_address_town,
                                                   :other_vehicle_owner_address_state, :other_vehicle_owner_address_zip,
                                                   :other_vehicle_owner_home_phone, :other_vehicle_owner_cell_phone,
                                                   :other_vehicle_owner_work_phone, :towed_from_scene,
                                                   :other_vehicle_towed_from_scene, :point_of_impact,
                                                   :damage_to_bus_point_of_impact,
                                                   :damage_to_other_vehicle_point_of_impact, :insurance_carrier,
                                                   :insurance_policy_number, :insurance_effective_date,
                                                   :property_owner_information_taken, :passenger_incident,
                                                   :inj_pax_info,
                                                   { injured_passengers_attributes: [:name, :address, :nature_of_injury,
                                                                                     :transported_to_hospital,
                                                                                     :home_phone, :cell_phone,
                                                                                     :work_phone] },
                                                   :occurred_front_door, :occurred_rear_door, :occurred_front_steps,
                                                   :occurred_rear_steps, :occurred_sudden_stop,
                                                   :occurred_before_boarding, :occurred_while_boarding,
                                                   :occurred_after_boarding, :occurred_while_exiting,
                                                   :occurred_after_exiting, :motion_of_bus, :condition_of_steps,
                                                   :bus_kneeled, :bus_up_to_curb, :bus_distance_from_curb,
                                                   :reason_not_up_to_curb, :vehicle_in_bus_stop_plate, :description)
    if data[:incidents]
      @incident.update latitude: data[:incidents][:latitude],
                       longitude: data[:incidents][:longitude]
    end
    unless data[:inj_pax_info] == '1'
      data.delete :injured_passengers_attributes
      @report.injured_passengers.destroy_all
    end
    data.except :inj_pax_info, :incidents
  end

  def set_report
    @report = IncidentReport.find params.require(:id)
    @incident = @report.incident
    return if current_user.staff?
    deny_access and return unless @report.user == current_user
  end
end
