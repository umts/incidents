# frozen_string_literal: true

require 'application_system_test_case'

class IncompleteIncidentsTest < ApplicationSystemTestCase
  test 'drivers cannot view incomplete incidents' do
    create :incident, :incomplete
    when_current_user_is :driver
    visit incidents_url

    assert_no_selector '.navbar button', text: 'Incomplete Incidents'
  end

  test 'staff can view incomplete incidents' do
    create :incident, :incomplete
    when_current_user_is :staff
    visit incidents_url

    within '.navbar' do
      assert_selector 'button', text: 'Incomplete Incidents'
      assert_selector 'button .number-icon', text: '1'
      click_button 'Incomplete Incidents'
    end

    assert_selector 'h1', text: 'Incomplete Incidents'
  end

  test 'incomplete incidents include only incomplete incidents' do
    incident_for 'Loralee Gusikowski'
    incident_for 'Sherryl Cartwright', :incomplete
    when_current_user_is :staff
    visit incomplete_incidents_url

    assert_no_incident_for 'Loralee Gusikowski'
    assert_incident_for 'Sherryl Cartwright'
  end

  test 'incomplete incidents redirects to the normal index if none' do
    when_current_user_is :staff
    visit incomplete_incidents_url

    assert_selector '.info p.notice', text: 'No incomplete incidents.'

    assert page.current_url.include? incidents_path
  end

  test 'incomplete incidents print properly' do
    create :incident, :incomplete
    when_current_user_is :staff
    visit incomplete_incidents_url

    click_button 'Print'

    assert_equal find('embed')['type'], 'application/pdf'
  end
end
