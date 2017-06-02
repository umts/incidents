# frozen_string_literal: true

require 'application_system_test_case'

class DeactivatingEmployeesTest < ApplicationSystemTestCase
  test 'employees cannot be deleted with incidents' do
    driver = (create :incident).driver
    when_current_user_is :staff
    visit users_url

    within 'table.index tbody tr:first-child' do
      assert_text driver.name
      click_button 'Delete'
    end

    assert_selector '.info p.alert', text: 'Cannot delete'
    assert_text driver.name
  end

  test 'employees can be deactivated by staff' do
    driver = (create :incident).driver
    when_current_user_is :staff
    visit users_url

    within 'table.index tbody tr:first-child' do
      assert_text driver.name
      click_button 'Deactivate'
    end

    assert_selector '.info p.notice', text: 'Driver was deactivated successfully.'

    assert_no_text driver.name
  end

  test 'employees can be reactivated by staff' do
    driver = create :user, active: false
    when_current_user_is :staff
    visit users_url(inactive: true)

    within first('table.index tbody tr') do
      click_button 'Reactivate'
    end

    assert_selector '.info p.notice', text: 'Driver was reactivated successfully.'
    assert_selector 'h1', text: 'Manage Active Drivers'

    assert_text driver.name
  end
end
