# frozen_string_literal: true

require 'application_system_test_case'

class ViewIncidentTest < ApplicationSystemTestCase
  test 'drivers can view their own incidents' do
    incident = create :incident
    when_current_user_is incident.driver
    visit incident_url(incident)

    assert_selector 'h1', text: 'Incident Report'
    assert_text incident.description
  end

  test 'drivers cannot view incidents of others' do
    when_current_user_is :driver
    visit incident_url(create :incident)

    assert_text 'You do not have permission to access this page.'
  end

  test 'regular incidents do not show special fields' do
    when_current_user_is :staff
    visit incident_url(create :incident)

    assert_text 'Motor vehicle collision? No'
    assert_text 'Passenger incident? No'

    assert_no_text 'Other vehicle plate #'
    assert_no_text 'Incident occurred:'
  end

  test 'motor vehicle collisions show the appropriate fields' do
    incident = create :incident, :collision

    when_current_user_is :staff
    visit incident_url(incident)

    assert_text 'Motor vehicle collision? Yes'

    assert_text 'Other vehicle plate #: ' + incident.other_vehicle_plate
    assert_text 'State: ' + incident.other_vehicle_state
    assert_text 'Model: ' + incident.other_vehicle_model
    assert_text 'Year: ' + incident.other_vehicle_year
    assert_text 'Color: ' + incident.other_vehicle_color
    # etc.
  end

  test 'other vehicle driver fields are shown if applicable' do
    incident = create :incident, :collision, :other_vehicle_not_driven_by_owner

    when_current_user_is :staff
    visit incident_url(incident)

    assert_text 'Vehicle owned by driver? No'

    assert_text 'Name of owner:'
  end

  test 'responding officer details are shown if applicable' do
    incident = create :incident, :collision, :police_on_scene

    when_current_user_is :staff
    visit incident_url(incident)

    assert_text 'Police on scene? Yes'

    assert_text 'Badge number:'
    assert_text 'Case number assigned:'
  end

  test 'passenger incidents show the appropriate fields' do
    incident = create :incident, :passenger_incident

    when_current_user_is :staff
    visit incident_url(incident)

    assert_text 'Passenger incident? Yes'

    assert_text 'Incident occurred: ' + incident.occurred_full_location
    assert_text 'Motion of bus:'
    assert_text 'Condition of steps:'
    # etc.
  end

  test 'reason not up to curb shown if applicable' do
    incident = create :incident, :passenger_incident, :not_up_to_curb

    when_current_user_is :staff
    visit incident_url(incident)

    assert_text 'Bus up to curb? No'

    assert_text 'Reason not up to curb:'
    assert_text 'Plate # of vehicle in bus stop'
  end

  test 'injured passenger information shown if applicable' do
    incident = create :incident, :passenger_incident, :injured_passenger

    when_current_user_is :staff
    visit incident_url(incident)

    assert_text 'Injured Passenger:'
  end

  test 'incidents show when they were last updated' do
    incident = create :incident
    staff_member = create :user, :staff
    when_current_user_is staff_member

    visit edit_incident_url(incident)
    fill_in 'Describe the incident in detail.', with: 'New description'
    click_on 'Save Incident'

    assert_selector '.info p.notice',
                    text: 'Incident report was successfully saved.'

    visit incident_url(incident)
    assert_text 'Last changed'
    assert_text "by #{staff_member.name}"
  end

  test 'incidents can be viewed in PDF form' do
    create :incident
    when_current_user_is :staff
    visit incidents_url

    click_button 'Print'

    assert_equal find('embed')['type'], 'application/pdf'
  end
end
