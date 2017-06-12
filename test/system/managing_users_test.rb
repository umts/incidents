# frozen_string_literal: true

require 'application_system_test_case'

class ManagingUsersTest < ApplicationSystemTestCase
  test 'staff can manage inactive users' do
    inactive_user = create :user, active: false
    when_current_user_is :staff

    visit users_url
    assert_selector 'h1', text: 'Active Drivers'
    assert_no_text inactive_user.name

    click_on 'Manage inactive drivers'
    assert_selector 'h1', text: 'Inactive Drivers'
    assert_text inactive_user.name

    click_on 'Manage active drivers'
    assert_selector 'h1', text: 'Active Drivers'
  end
end
