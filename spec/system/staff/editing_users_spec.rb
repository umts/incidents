# frozen_string_literal: true

require 'spec_helper'

describe 'editing users as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let!(:driver) { create :user, :driver }
  it 'allows making changes', js: true  do
    visit users_url
    click_button 'Drivers'
    expect(page).to have_selector 'button',
      text: 'Edit', count: 1
    click_button 'Edit'
    expect(page.current_url).to end_with edit_user_path(driver)
    expect(page).to have_selector 'h1',
      text: "Editing #{driver.full_name}"
    fill_in 'First name', with: 'Newname'
    click_button 'Save user'
    expect(page).to have_selector 'p.notice',
      text: 'User was updated successfully.'
    expect(page).to have_text 'Newname'
  end
  it 'displays errors if there are any', js: true  do
    visit edit_user_url(driver)
    fill_in 'First name', with: ''
    click_button 'Save user'
    expect(page).to have_text 'This user has 1 missing value and so cannot be saved:'
    expect(page).to have_text "First name can't be blank"
  end
  it 'allows resetting passwords', js: true  do
    visit users_url
    click_button 'Drivers'
    expect(page).to have_selector 'button',
      text: 'Reset Password', count: 1
    click_button 'Reset Password'
    expect(page).to have_selector 'p.notice',
      text: "#{driver.full_name}'s password was reset to the default password."

    click_button 'Logout'
    fill_in 'Badge number', with: driver.badge_number
    fill_in 'Password', with: driver.last_name
    click_button 'Log in'
    expect(page).to have_selector 'p.notice',
      text: 'Signed in successfully.'
  end
end
