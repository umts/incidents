# frozen_string_literal: true

require 'application_system_test_case'

class EditIncidentTest < ApplicationSystemTestCase
  test 'drivers can complete incomplete incidents' do
    incident = create :incident, :incomplete
    when_current_user_is incident.driver
    visit incidents_url

    within 'table.incidents' do
      assert_selector 'button', text: 'Complete'
      click_button 'Complete'
    end

    assert_selector 'h1', text: 'Editing Incident'
  end

  test 'drivers can edit unreviewed incidents' do
    incident = create :incident
    when_current_user_is incident.driver
    visit incidents_url

    within 'table.incidents' do
      assert_selector 'button', text: 'Edit'
      click_button 'Edit'
    end

    assert_selector 'h1', text: 'Editing Incident'
  end

  test 'drivers cannot edit reviewed incidents' do
    incident = create :incident, :reviewed
    when_current_user_is incident.driver
    visit incidents_url

    assert_no_selector 'table.incidents button', text: 'Edit'
  end

  test 'drivers can make changes to incidents' do
    incident = create :incident
    when_current_user_is incident.driver
    visit edit_incident_url(incident)

    fill_in 'incident[run]', with: 'A new run'
    click_button 'Save Incident'

    assert_selector '.info p.notice', text: 'Incident report was successfully saved.'

    visit incident_url(incident)

    assert_selector 'p', text: 'Run: A new run'
  end

  test 'incomplete fields do not show an error message' do
    incident = create :incident, :incomplete
    when_current_user_is incident.driver
    visit edit_incident_url(incident)

    fill_in 'incident[run]', with: 'Just a run'
    click_button 'Save Incident'

    assert_no_selector '#error_explanation'
  end

  test 'staff can edit other incidents' do
    create :incident
    create :incident, :reviewed

    when_current_user_is :staff
    visit incidents_url

    within 'table.incidents tbody' do
      assert_selector 'button', text: 'Edit', count: 2
    end
  end
end
