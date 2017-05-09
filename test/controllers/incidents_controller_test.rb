require 'test_helper'

class IncidentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @incident = incidents(:one)
  end

  test "should get index" do
    get incidents_url
    assert_response :success
  end

  test "should get new" do
    get new_incident_url
    assert_response :success
  end

  test "should create incident" do
    assert_difference('Incident.count') do
      post incidents_url, params: { incident: { action_before: @incident.action_before, action_during: @incident.action_during, camera_used: @incident.camera_used, damage: @incident.damage, description: @incident.description, driver: @incident.driver, injuries: @incident.injuries, light_conditions: @incident.light_conditions, location: @incident.location, occurred_at: @incident.occurred_at, road_conditions: @incident.road_conditions, route: @incident.route, shift: @incident.shift, vehicle: @incident.vehicle, weather_conditions: @incident.weather_conditions } }
    end

    assert_redirected_to incident_url(Incident.last)
  end

  test "should show incident" do
    get incident_url(@incident)
    assert_response :success
  end

  test "should get edit" do
    get edit_incident_url(@incident)
    assert_response :success
  end

  test "should update incident" do
    patch incident_url(@incident), params: { incident: { action_before: @incident.action_before, action_during: @incident.action_during, camera_used: @incident.camera_used, damage: @incident.damage, description: @incident.description, driver: @incident.driver, injuries: @incident.injuries, light_conditions: @incident.light_conditions, location: @incident.location, occurred_at: @incident.occurred_at, road_conditions: @incident.road_conditions, route: @incident.route, shift: @incident.shift, vehicle: @incident.vehicle, weather_conditions: @incident.weather_conditions } }
    assert_redirected_to incident_url(@incident)
  end

  test "should destroy incident" do
    assert_difference('Incident.count', -1) do
      delete incident_url(@incident)
    end

    assert_redirected_to incidents_url
  end
end
