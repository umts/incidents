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

    fill_in 'incident[shift]', with: 'A new shift'
    click_button 'Update Incident'

    assert_selector '.info p.notice', text: 'Incident was successfully updated.'
    
    visit incident_url(incident)

    assert_selector 'p', text: 'Shift: A new shift'
  end

  test 'incomplete fields shows an error message' do
    incident = create :incident, :incomplete
    when_current_user_is incident.driver
    visit edit_incident_url(incident)

    fill_in 'incident[shift]', with: 'Just a shift'
    click_button 'Update Incident'

    assert_selector '#error_explanation'
    within '#error_explanation' do
      assert_text "Route can't be blank"
      assert_text "Vehicle can't be blank"
      # etc.
    end
  end

  test 'staff cannot edit incomplete incidents' do
    create :incident, :incomplete

    when_current_user_is :staff
    visit incidents_url

    within 'table.incidents' do
      assert_no_selector 'button', text: 'Edit'
    end
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
