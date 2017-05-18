# frozen_string_literal: true

require 'application_system_test_case'

class NewUserTest < ApplicationSystemTestCase
  test 'drivers cannot create new users' do
    when_current_user_is :driver
    visit incidents_url
    assert_no_selector '.navbar button', text: 'New Driver'
  end

  test 'staff members can create new users' do
    when_current_user_is :staff
    visit incidents_url
    assert_selector '.navbar button', text: 'New Driver'

    click_button 'New Driver'

    assert_selector 'h1', text: 'New Driver'
  end

  test 'users can be created with all the correct attributes' do
    when_current_user_is :staff
    visit new_user_url
    within '.edit-form' do
      fill_in 'Name', with: 'Gabriel Tremblay'
      fill_in 'Email', with: 'gabriel@example.com'
      fill_in 'Password', with: 'cherries'
      fill_in 'Password confirmation', with: 'cherries'
      click_button 'Save driver'
    end

    assert_selector '.info p.notice', text: 'Driver was created.'

    click_button 'Logout'

    within 'form.new_user' do
      fill_in 'Email', with: 'gabriel@example.com'
      fill_in 'Password', with: 'cherries'
      click_button 'Log in'
    end

    assert_selector '.info p.notice', text: 'Signed in successfully.'
  end

  test 'specifying mismatched passwords shows a warning notice' do
    when_current_user_is :staff
    visit new_user_url
    within '.edit-form' do
      fill_in 'Name', with: 'Gabriel Tremblay'
      fill_in 'Email', with: 'gabriel@example.com'
      fill_in 'Password', with: 'cherries'
      fill_in 'Password confirmation', with: 'dates'
      click_button 'Save driver'
    end

    assert_selector '.info p.errors',
                    text: "Password confirmation doesn't match Password"
  end
end
