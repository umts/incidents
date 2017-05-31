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
end
