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

  # TODO: test that editing actually works for drivers
  
  # TODO: test that staff can edit any kind of incident
end
