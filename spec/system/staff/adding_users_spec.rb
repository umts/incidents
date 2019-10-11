# frozen_string_literal: true

require 'spec_helper'

describe 'adding users as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }

  it 'allows adding users' do
    visit users_url
    click_on 'Add New User'
    expect(page).to have_content 'First name'
    expect(page).to have_content 'Last name'
    expect(page).to have_content 'Badge number'
    expect(page).to have_content 'Divisions'
    expect(page.current_url).to end_with new_user_path
    expect(page).to have_selector 'h1', text: 'Add New User'
  end

  it 'requires first name, last name, badge number, and divisions' do
    visit new_user_url
    click_button 'Save user'
    wait_for_ajax!
    expect(page).to have_selector 'p',
      text: 'This user has 4 missing values and so cannot be saved:'
    expect(page).to have_text "First name can't be blank"
    expect(page).to have_text "Last name can't be blank"
    expect(page).to have_text "Badge number can't be blank"
    expect(page).to have_text "Divisions can't be blank"
  end

  it 'accepts new users which have the required values' do
    create :division, name: 'UMASS'
    visit new_user_url
    fill_in 'First name', with: 'Leopold'
    fill_in 'Last name', with: 'Markowski'
    fill_in 'Badge number', with: '4087'
    select 'UMASS', from: 'Divisions'
    click_button 'Save user'
    expect(page).to have_selector 'p.notice',
      text: 'User was successfully created.'
    expect(page.current_url).to end_with users_path
  end

  it 'gives new users the default password' do
    new_user = build :user, :driver
    visit new_user_url
    fill_in 'First name', with: new_user.first_name
    fill_in 'Last name', with: new_user.last_name
    fill_in 'Badge number', with: new_user.badge_number
    select  new_user.division.name, from: 'Divisions'
    click_button 'Save user'

    user = User.find_by(badge_number: new_user.badge_number)
    expect(user.valid_password? user.last_name).to be true
    expect(user.password_changed_from_default?).to be false
  end
end
