require 'application_system_test_case'

class UnreviewedIncidentsTest < ApplicationSystemTestCase
  test 'drivers cannot view unreviewed incidents' do
    create :incident
    when_current_user_is :driver
    visit incidents_url

    assert_no_selector '.navbar button', text: 'Unreviewed Incidents'
  end

  test 'staff can view unreviewed incidents' do
    create :incident
    when_current_user_is :staff
    visit incidents_url

    within '.navbar' do
      assert_selector 'button', text: 'Unreviewed Incidents'
      assert_selector 'button .number-icon', text: '1'
      click_button 'Unreviewed Incidents'
    end

    assert_selector 'h1', text: 'Unreviewed Incidents'
  end

  test 'unreviewed incidents include only unreviewed incidents' do
    incident_for 'Loralee Gusikowski', :reviewed
    incident_for 'Sherryl Cartwright'
    when_current_user_is :staff
    visit unreviewed_incidents_url

    assert_no_incident_for 'Loralee Gusikowski'
    assert_incident_for 'Sherryl Cartwright'
  end

  test 'unreviewed incidents redirects to the normal index if none' do
    when_current_user_is :staff
    visit unreviewed_incidents_url

    assert_selector '.info p.notice', text: 'No unreviewed incidents.'

    assert page.current_url.include? incidents_path
  end
end
