# frozen_string_literal: true

require 'spec_helper'

describe 'changing your password' do
  let(:user) { create :user, :default_password }
  let(:old_password) { 'BadOldPassword' }
  let(:new_password) { 'GreatNewPassword' }
  before :each do
    user.update(password: old_password, password_confirmation: old_password)
    when_current_user_is user
    visit change_password_path
  end

  it 'requires your existing password' do
    fill_in 'Password', with: new_password
    fill_in 'Password confirmation', with: new_password
    click_on 'Change password'

    expect(page).to have_current_path user_registration_path(user)
    expect(page).to have_text "Current password can't be blank"
  end

  it 'requires a password confirmation' do
    fill_in 'Password', with: new_password
    fill_in 'Current password', with: old_password
    click_on 'Change password'

    expect(page).to have_current_path user_registration_path(user)
    expect(page).to have_text "Password confirmation doesn't match Password"
  end

  it 'yells at you if you leave your password blank' do
    fill_in 'Current password', with: old_password
    click_on 'Change password'

    expect(page).to have_current_path change_password_path
    expect(page).to have_text 'Password cannot be blank'
  end

  it 'actually changes your password' do
    fill_in 'Password', with: new_password
    fill_in 'Password confirmation', with: new_password
    fill_in 'Current password', with: old_password
    click_on 'Change password'

    expect(page).to have_current_path root_path
    expect(page).to have_text 'password has been successfully changed'
    expect(user.reload.valid_password? new_password).to be true
  end
end
