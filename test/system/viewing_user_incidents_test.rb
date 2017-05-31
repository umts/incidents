# frozen_string_literal: true

require 'application_system_test_case'

class ViewingUserIncidentsTest < ApplicationSystemTestCase
  test 'staff can view incidents by driver' do
    create :user, :driver, name: 'Tommie Gorczany'
    when_current_user_is :staff
    visit users_url

    within first('tbody tr') do
      assert_selector 'button', text: 'View incidents'
      click_button 'View incidents'
    end

    assert_selector 'h1', text: "Tommie Gorczany's Incidents"
  end

  test 'staff cannot view incidents by inactive drivers' do
    inactive_user = create :user, :driver, active: false
    create :incident, driver: inactive_user

    visit users_url

    assert_no_text inactive_user.name
  end

  test 'only incidents from the driver are included' do
    incident = create :incident
    some_other_incident = create :incident
    when_current_user_is :staff
    visit incidents_user_url(incident.driver)

    within 'table.incidents tbody' do
      assert_selector 'tr', count: 1
      assert_no_selector 'td', text: some_other_incident.driver.name
    end
  end

  test 'drivers cannot view incidents by driver' do
    when_current_user_is :driver
    visit incidents_user_url(create :user, :driver)

    assert_text 'You do not have permission to access this page.'
  end
end
