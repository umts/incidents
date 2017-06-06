# frozen_string_literal: true

require 'application_system_test_case'

class IncidentsHistoryTest < ApplicationSystemTestCase
  test 'new incidents show just the driver having been edited' do
    staff = create :user, :staff
    driver = create :user, :driver
    when_current_user_is staff
    visit new_incident_url

    select driver.name, from: 'Driver'
    create_time = 5.minutes.ago
    Timecop.freeze create_time do
      click_button 'Save Incident'
    end

    visit incident_url(Incident.last)
    click_on 'View full history'
    assert_text 'Incident History'

    assert_selector 'table.history>tbody>tr', count: 1
    within first('table.history>tbody>tr') do
      assert_text staff.name
      assert_text create_time.min
      assert_text 'initialized the incident report'
      assert_selector 'table.changes tbody tr', count: 1
      within first('table.changes tbody tr') do
        assert_text 'Driver'
        assert_text 'Blank'
        assert_text driver.name
      end
    end
  end

  test 'changing a value shows the change made' do
    incident = create :incident, description: 'Old description'
    when_current_user_is :staff
    visit edit_incident_url(incident)

    fill_in 'Describe the incident in detail.', with: 'New description'
    click_on 'Save Incident'

    visit history_incident_url(incident)

    within find_all('table.history>tbody>tr').last do
      assert_text 'changed incident report data'

      assert_selector 'table.changes tbody tr', count: 1
      within first('table.changes tbody tr') do
        assert_text 'Describe the incident in detail.'
        assert_text 'Old description'
        assert_text 'New description'
      end
    end
  end
end
