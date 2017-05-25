require 'application_system_test_case'

class CompletingIncidentsTest < ApplicationSystemTestCase
  test 'drivers can fill in basic fields and submit incidents' do
    incident = create :incident, :incomplete

    when_current_user_is incident.driver
    visit edit_incident_url(incident)

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

    assert_selector '.info p.notice', text: 'Incident was successfully updated.'
  end

  test 'drivers can fill in motor vehicle collision fields' do
    incident = create :incident, :incomplete

    when_current_user_is incident.driver
    visit edit_incident_url(incident)

    assert_no_text 'Motor Vehicle Collision Information'
    check 'Motor vehicle collision'
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

    assert_selector '.info p.notice', text: 'Incident was successfully updated.'
  end

  test 'drivers can fill in responding officer information' do
    incident = create :incident, :incomplete

    when_current_user_is incident.driver
    visit edit_incident_url(incident)

    check 'Motor vehicle collision'

    assert_no_selector '.police-info'
    check 'Police on scene'
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

    assert_selector '.info p.notice', text: 'Incident was successfully updated.'
  end

  test 'drivers can fill in vehicle owner information' do
    incident = create :incident, :incomplete

    when_current_user_is incident.driver
    visit edit_incident_url(incident)

    check 'Motor vehicle collision'

    fill_in_basic_fields
    fill_in_motor_vehicle_collision_fields

    assert_no_selector '.other-vehicle-owner-info'
    uncheck 'Other vehicle owned by other driver'
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

    assert_selector '.info p.notice', text: 'Incident was successfully updated.'
  end

  test 'drivers can fill in passenger incident information' do
    incident = create :incident, :incomplete

    when_current_user_is incident.driver
    visit edit_incident_url(incident)


    assert_no_text 'Passenger Incident Information'
    check 'Passenger incident'
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

    assert_selector '.info p.notice', text: 'Incident was successfully updated.'
  end

  test 'drivers can fill in a reason for not being up to the curb if applicable' do
    incident = create :incident, :incomplete

    when_current_user_is incident.driver
    visit edit_incident_url(incident)

    check 'Passenger incident'

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

    assert_selector '.info p.notice', text: 'Incident was successfully updated.'
  end

  def fill_in_basic_fields
    fill_in 'Run', with: '30-3 EVE'
    fill_in 'Block', with: '303'
    fill_in 'Bus', with: '3308'
    fill_in 'Passengers onboard', with: 13
    fill_in 'Courtesy cards distributed', with: 0
    fill_in 'Courtesy cards collected', with: 0
    fill_in 'Speed', with: 14
    fill_in 'Location', with: 'Main St. and S. East St'
    fill_in 'Town', with: 'Amherst'
    select 'Raining', from: 'Weather conditions'
    select 'Wet', from: 'Road conditions'
    select 'Daylight', from: 'Light conditions'
    check 'Headlights used'
    fill_in 'Description', with: 'I was preparing to make the right turn when a car went around me.'
  end

  def fill_in_motor_vehicle_collision_fields
    fill_in 'Other vehicle plate', with: '8CHZ50'
    fill_in 'Other vehicle state', with: 'MA'
    fill_in 'Other vehicle make', with: 'Nissan'
    fill_in 'Other vehicle model', with: 'Integra'
    fill_in 'Other vehicle year', with: '1993'
    fill_in 'Other vehicle color', with: 'White'
    fill_in 'Other vehicle passengers', with: 1
    select 'East', from: 'Direction'
    select 'East', from: 'Other vehicle direction'
    fill_in 'Other driver name', with: 'Nico Rosberg'
    fill_in 'Other driver license number', with: 'S10354298'
    fill_in 'Other driver license state', with: 'MA'
    fill_in 'Other vehicle driver address', with: '23 Wins St'
    fill_in 'Other vehicle driver address town', with: 'Championsville'
    fill_in 'Other vehicle driver address state', with: 'MA'
    fill_in 'Other vehicle driver address zip', with: '00001'
    fill_in 'Other vehicle driver home phone', with: '413 555 0056'
    fill_in 'Damage to bus point of impact', with: 'Scratches'
    fill_in 'Damage to other vehicle point of impact', with: 'Scratches'
    fill_in 'Insurance carrier', with: 'Progressive'
    fill_in 'Insurance policy number', with: '58925948'
    check 'Other vehicle owned by other driver'
  end

  def fill_in_police_fields
    fill_in 'Police badge number', with: '1024'
    fill_in 'Police town or state', with: 'Amherst'
    fill_in 'Police case assigned', with: 'C34059'
  end

  def fill_in_other_vehicle_owner_fields
    fill_in 'Other vehicle owner name', with: 'Lewis Hamilton'
    fill_in 'Other vehicle owner address', with: '55 Wins St'
    fill_in 'Other vehicle owner address town', with: 'Championsville'
    fill_in 'Other vehicle owner address state', with: 'MA'
    fill_in 'Other vehicle owner address zip', with: '00001'
    fill_in 'Other vehicle owner home phone', with: '413 555 0056'
  end

  def fill_in_passenger_incident_fields
    check 'Occurred front door'
    check 'Occurred sudden stop'
    select 'Braking', from: 'Motion of bus'
    select 'Dry', from: 'Condition of steps'
  end
end
