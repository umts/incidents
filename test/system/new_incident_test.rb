require 'application_system_test_case'

class NewIncidentTest < ApplicationSystemTestCase
  test 'drivers cannot create new incidents' do
    when_current_user_is :driver
    visit incidents_url
    assert_no_selector '.navbar button', text: 'New Incident'

  end

  test 'staff members can create new incidents' do
    when_current_user_is :staff
    visit incidents_url
    assert_selector '.navbar button', text: 'New Incident'

    click_button 'New Incident'

    assert_selector 'h1', 'New Incident'
  end

  test 'staff members need only specify the incident driver' do
    when_current_user_is :staff
    visit new_incident_url

    within 'form' do
      assert_selector '.field label', text: 'Driver'
      assert_selector '.field select'
      assert_equal find('.field select')['name'], 'incident[driver_id]'

      assert_no_selector '.field label', text: 'Occurred at'
      assert_no_selector '.field label', text: 'Shift'
      assert_no_selector '.field label', text: 'Route'
      # etc.
    end

  end

  test 'staff members can specify the incident driver and create an incomplete incident' do
    driver = create :user, :driver

    when_current_user_is :staff
    visit new_incident_url

    within 'form' do
      select driver.name, from: 'incident[driver_id]'
      click_button 'Create Incident'
    end

    within '.navbar' do
      assert_selector 'button', text: 'Incomplete Incidents'
      assert_selector 'button .number-icon', text: '1'
      click_button 'Incomplete Incidents'
    end

    assert_selector 'h1', text: 'Incomplete Incidents'
    assert_selector 'table.incidents td', text: driver.name
  end
end
