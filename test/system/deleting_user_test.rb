require 'application_system_test_case'

class DeletingUserTest < ApplicationSystemTestCase
  test 'drivers cannot manage users' do
    when_current_user_is :driver
    visit incidents_url
    
    assert_no_selector '.navbar button', text: 'Manage Users'

    visit users_url
    assert_text 'You do not have permission to access this page.'
  end

  test 'staff members can manage users' do
    when_current_user_is :staff
    visit incidents_url

    assert_selector '.navbar button', text: 'Manage Users'
    click_button 'Manage Users'

    assert_selector 'h1', text: 'Manage Users'
  end

  test 'staff members can delete users' do
    create :user, :driver, name: 'Shannon Schmidt'
    create :user, :staff, name: 'Rozanne Schaefer'
    when_current_user_is 'Rozanne Schaefer'
    visit users_url

    within 'table.index tbody' do
      assert_selector 'td', text: 'Shannon Schmidt'
      assert_selector 'td', text: 'Rozanne Schaefer'
      assert_selector 'button', text: 'Delete', count: 2
      within(first('tr')) { click_button 'Delete' }
    end

    assert_selector '.info p.notice', text: 'User was deleted.'
  end
end
