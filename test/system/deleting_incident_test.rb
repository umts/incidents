require 'application_system_test_case'

class DeletingIncidentTest < ApplicationSystemTestCase
  test 'drivers cannot delete incidents' do
    incident = create :incident
    when_current_user_is incident.driver

    visit incidents_url

    assert_no_selector 'table.incidents button', text: 'Delete'
  end

  test 'staff members can delete incidents' do
    create :incident, occurred_at: Time.zone.now
    when_current_user_is :staff

    visit incidents_url

    within 'table.incidents tbody tr' do
      assert_selector 'button.delete', text: 'Delete'
      click_button 'Delete'
    end

    assert_selector '.info p.notice', text: 'Incident was successfully deleted.'

    assert_no_selector 'table.incidents tbody tr'
  end
end
