# frozen_string_literal: true

require 'application_system_test_case'

class EditUserTest < ApplicationSystemTestCase
  test 'staff members can edit users' do
    create :user, :driver, name: 'Sherman Bayer'
    when_current_user_is :staff
    visit users_url

    within first('table.index tbody tr') do
      assert_selector 'button', text: 'Edit'
      click_button 'Edit'
    end

    assert_selector 'h1', text: 'Editing Sherman Bayer'
  end

  test 'staff members can reset passwords' do
    driver = create :user, :driver
    when_current_user_is :staff
    visit edit_user_url(driver)

    within '.edit-form' do
      fill_in 'Password', with: 'grapefruits'
      fill_in 'Password confirmation', with: 'grapefruits'
      click_button 'Save driver'
    end

    assert_selector '.info p.notice', text: 'Driver was updated successfully.'

    click_button 'Logout'

    within 'form.new_user' do
      fill_in 'Email', with: driver.email
      fill_in 'Password', with: 'grapefruits'
      click_button 'Log in'
    end

    assert_selector '.info p.notice', text: 'Signed in successfully.'
  end

  test 'staff members can edit user fields without changing their password' do
    driver = create :user, :driver
    when_current_user_is :staff
    visit edit_user_url(driver)

    within '.edit-form' do
      fill_in 'Name', with: 'Laureen Klein'
      click_button 'Save driver'
    end

    assert_selector '.info p.notice', text: 'Driver was updated successfully.'

    within first('table.index tbody tr') do
      assert_selector 'td', text: 'Laureen Klein'
    end
  end
end
