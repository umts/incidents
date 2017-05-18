# frozen_string_literal: true

require 'application_system_test_case'

class AuthenticationTest < ApplicationSystemTestCase
  test 'users can log in with correct credentials' do
    user = create :user, password: 'bananas', password_confirmation: 'bananas'
    visit root_url

    within 'form.new_user' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'
    end

    assert_selector '.info p.notice', text: 'Signed in successfully.'
    assert_selector 'h1', text: 'Your Incidents'
  end

  test 'users cannot log in with incorrect credentials' do
    visit root_url

    within 'form.new_user' do
      fill_in 'Email', with: 'dave@example.com'
      fill_in 'Password', with: 'something obviously wrong'
      click_button 'Log in'
    end

    assert_selector '.info p.alert', text: 'Invalid Email or password.'
  end

  test 'logged in users can change their password' do
    user = create :user, password: 'bananas', password_confirmation: 'bananas'
    when_current_user_is user
    visit root_url

    assert_selector '.navbar button', text: 'Change Password'
    click_button 'Change Password'

    assert_selector 'h1', text: 'Changing your password'

    within 'form.edit_user' do
      fill_in 'Password', with: 'apples'
      fill_in 'Password confirmation', with: 'apples'
      fill_in 'Current password', with: 'bananas'
      click_button 'Update'
    end

    assert_selector '.info p.notice',
                    text: 'Your account has been updated successfully.'

    click_button 'Logout'

    within 'form.new_user' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: 'apples'
      click_button 'Log in'
    end

    assert_selector '.info p.notice', text: 'Signed in successfully.'
  end
end
