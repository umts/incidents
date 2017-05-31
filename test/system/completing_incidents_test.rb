# frozen_string_literal: true

require 'application_system_test_case'

class CompletingIncidentsTest < ApplicationSystemTestCase
  test 'drivers can submit incidents regardless of completeness' do
    incident = create :incident, :incomplete

    when_current_user_is incident.driver
    visit edit_incident_url(incident)

    click_on 'Save Incident'

    assert_no_selector '#error_explanation'
    assert_selector '.info p.notice', text: 'Incident report was successfully saved.'
  end

  test 'staff can fill in basic fields and submit incidents' do
    when_current_user_is :staff
    visit edit_incident_url(create :incident, :incomplete)

    check 'Completed'
    click_on 'Save Incident'

    assert_selector '#error_explanation'
    within '#error_explanation' do
      assert_text "Run can't be blank"
      assert_text "Block can't be blank"
      assert_text "Bus can't be blank"
      # etc.
    end

    fill_in_basic_fields

    click_on 'Save Incident'

    assert_selector '.info p.notice', text: 'Incident report was successfully saved.'
  end

  test 'users can fill in motor vehicle collision fields' do
    when_current_user_is :staff
    visit edit_incident_url(create :incident, :incomplete)

    check 'Completed'

    assert_no_text 'Motor Vehicle Collision Information'
    check 'Did the incident involve a collision with a motor vehicle?'
    assert_text 'Motor Vehicle Collision Information'

    fill_in_basic_fields

    click_on 'Save Incident'

    assert_selector '#error_explanation'
    within '#error_explanation' do
      assert_text "Other vehicle plate can't be blank"
      assert_text "Other vehicle state can't be blank"
      assert_text "Other vehicle make can't be blank"
      # etc.
    end
    fill_in_motor_vehicle_collision_fields

    click_on 'Save Incident'

    assert_selector '.info p.notice', text: 'Incident report was successfully saved.'
  end

  test 'users can fill in responding officer information' do
    when_current_user_is :staff
    visit edit_incident_url(create :incident, :incomplete)

    check 'Completed'

    check 'Did the incident involve a collision with a motor vehicle?'

    assert_no_selector '.police-info'
    check 'Did police respond to the incident?'
    assert_selector '.police-info'

    fill_in_basic_fields
    fill_in_motor_vehicle_collision_fields

    click_on 'Save Incident'

    assert_selector '#error_explanation'
    within '#error_explanation' do
      assert_text "Police badge number can't be blank"
      assert_text "Police town or state can't be blank"
      assert_text "Police case assigned can't be blank"
    end

    fill_in_police_fields

    click_on 'Save Incident'

    assert_selector '.info p.notice', text: 'Incident report was successfully saved.'
  end

  test 'users can fill in vehicle owner information' do
    when_current_user_is :staff
    visit edit_incident_url(create :incident, :incomplete)

    check 'Completed'

    check 'Did the incident involve a collision with a motor vehicle?'

    fill_in_basic_fields
    fill_in_motor_vehicle_collision_fields

    assert_no_selector '.other-vehicle-owner-info'
    uncheck 'Is the other driver involved the owner of the vehicle?'
    assert_selector '.other-vehicle-owner-info'

    click_on 'Save Incident'

    assert_selector '#error_explanation'
    within '#error_explanation' do
      assert_text "Other vehicle owner name can't be blank"
      assert_text "Other vehicle owner address can't be blank"
      assert_text "Other vehicle owner address town can't be blank"
      # etc.
    end

    fill_in_other_vehicle_owner_fields

    click_on 'Save Incident'

    assert_selector '.info p.notice', text: 'Incident report was successfully saved.'
  end

  test 'users can fill in passenger incident information' do
    when_current_user_is :staff
    visit edit_incident_url(create :incident, :incomplete)

    check 'Completed'

    assert_no_text 'Passenger Incident Information'
    check 'Did the incident involve a passenger?'
    assert_text 'Passenger Incident Information'

    fill_in_basic_fields

    click_on 'Save Incident'

    assert_selector '#error_explanation'
    within '#error_explanation' do
      assert_text "Motion of bus can't be blank"
      assert_text "Condition of steps can't be blank"
    end

    fill_in_passenger_incident_fields

    click_on 'Save Incident'

    assert_selector '.info p.notice', text: 'Incident report was successfully saved.'
  end

  test 'users can fill in a reason for not being at the curb if applicable' do
    when_current_user_is :staff
    visit edit_incident_url(create :incident, :incomplete)

    check 'Completed'

    check 'Did the incident involve a passenger?'

    fill_in_basic_fields
    fill_in_passenger_incident_fields

    assert_no_selector '.reason-not-up-to-curb-info'
    select 'Stopped', from: 'Motion of bus'
    uncheck 'Bus up to curb'
    assert_selector '.reason-not-up-to-curb-info'

    click_on 'Save Incident'

    assert_selector '#error_explanation'
    within '#error_explanation' do
      assert_text "Reason not up to curb can't be blank"
    end

    fill_in 'Reason not up to curb', with: "I didn't feel like it."

    click_on 'Save Incident'

    assert_selector '.info p.notice', text: 'Incident report was successfully saved.'
  end

  test 'users can fill in injured passenger information' do
    when_current_user_is :staff
    visit edit_incident_url(create :incident, :incomplete)

    check 'Completed'

    check 'Did the incident involve a passenger?'

    fill_in_basic_fields
    fill_in_passenger_incident_fields

    assert_no_selector '.injured-passenger-info'
    check 'Passenger injured'
    assert_selector '.injured-passenger-info'

    click_on 'Save Incident'

    assert_selector '#error_explanation'
    within '#error_explanation' do
      assert_text 'Injured passenger must have name, address, town' # etc.
    end

    fill_in_injured_passenger_fields

    click_on 'Save Incident'

    assert_selector '.info p.notice', text: 'Incident report was successfully saved.'
  end

  def fill_in_basic_fields
    within '.basic-info' do
      fill_in 'Run #', with: '30-3 EVE'
      fill_in 'Block #', with: '303'
      fill_in 'Bus #', with: '3308'
      fill_in 'Passengers onboard', with: 13
      fill_in 'Courtesy cards distributed', with: 0
      fill_in 'Courtesy cards collected', with: 0
      fill_in 'Speed at time of incident', with: 14
      fill_in 'Location', with: 'Main St. and S. East St'
      fill_in 'Town', with: 'Amherst'
      select 'Raining', from: 'Weather conditions'
      select 'Wet', from: 'Road conditions'
      select 'Daylight', from: 'Light conditions'
      check 'Were the bus headlights on at the time of the incident?'
    end
    fill_in 'Description of incident',
            with: 'I was making the right turn when a car went around me.'
  end

  def fill_in_motor_vehicle_collision_fields
    within '.motor-vehicle-collision-info' do
      fill_in 'License plate of other vehicle', with: '8CHZ50'
      fill_in 'State registered', with: 'MA'
      fill_in 'Make', with: 'Nissan'
      fill_in 'Model', with: 'Integra'
      fill_in 'Year', with: '1993'
      fill_in 'Color', with: 'White'
      fill_in '# of passengers in other vehicle', with: 1
      select 'East', from: 'Direction bus was travelling'
      select 'East', from: 'Direction other vehicle was travelling'
      fill_in 'Driver of other vehicle', with: 'Nico Rosberg'
      fill_in "Other driver's license number", with: 'S10354298'
      fill_in 'State of license', with: 'MA'
      fill_in 'Address of other driver', with: '23 Wins St'
      fill_in 'Town', with: 'Championsville'
      fill_in 'State', with: 'MA'
      fill_in 'Zip', with: '00001'
      fill_in 'Home phone #', with: '413 555 0056'
      fill_in 'Damage to bus at point of impact', with: 'Scratches'
      fill_in 'Damage to other vehicle at point of impact', with: 'Scratches'
      fill_in "Other driver's insurance carrier", with: 'Progressive'
      fill_in 'Policy #', with: '58925948'
      check 'Is the other driver involved the owner of the vehicle?'
    end
  end

  def fill_in_police_fields
    within '.motor-vehicle-collision-info' do
      fill_in 'Police badge number', with: '1024'
      fill_in 'Police town or state', with: 'Amherst'
      fill_in 'Police case assigned', with: 'C34059'
    end
  end

  def fill_in_other_vehicle_owner_fields
    within '.motor-vehicle-collision-info' do
      fill_in 'Other vehicle owner name', with: 'Lewis Hamilton'
      fill_in 'Other vehicle owner address', with: '55 Wins St'
      fill_in 'Other vehicle owner address town', with: 'Championsville'
      fill_in 'Other vehicle owner address state', with: 'MA'
      fill_in 'Other vehicle owner address zip', with: '00001'
      fill_in 'Other vehicle owner home phone', with: '413 555 0056'
    end
  end

  def fill_in_passenger_incident_fields
    check 'Occurred front door'
    check 'Occurred sudden stop'
    select 'Braking', from: 'Motion of bus'
    select 'Dry', from: 'Condition of steps'
  end

  def fill_in_injured_passenger_fields
    within '.injured-passenger-info' do
      fill_in 'Name', with: 'Fernando Alonso'
      fill_in 'Address', with: '32 Wins St'
      fill_in 'Town', with: 'Championsville'
      fill_in 'State', with: 'MA'
      fill_in 'Zip', with: '00001'
      fill_in 'Phone', with: '413 555 0056'
    end
  end
end
