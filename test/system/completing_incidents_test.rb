require 'application_system_test_case'

class CompletingIncidentsTest < ApplicationSystemTestCase
  test 'drivers can fill out basic fields and submit incidents' do
    incident = create :incident, :incomplete

    when_current_user_is incident.driver
    visit edit_incident_url(incident)

    fill_in_basic_fields

    click_on 'Save Incident'

    assert_selector '.info p.notice', text: 'Incident was successfully updated.'
  end

  test 'drivers can fill out motor vehicle collision fields' do
    incident = create :incident, :incomplete

    when_current_user_is incident.driver
    visit edit_incident_url(incident)

    fill_in_basic_fields

    check 'Motor vehicle collision'
    assert_text 'Motor Vehicle Collision Information'

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
end
