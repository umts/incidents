# frozen_string_literal: true

require 'spec_helper'

describe 'viewing users as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  it 'allows viewing users' do
    visit root_url
    click_button 'Manage Users'
    expect(page.current_url).to end_with users_path
    expect(page).to have_selector 'h1', text: 'Active Users'
  end
  it 'displays users from all divisions' do
    different_division_user = create :user
    visit users_url
    expect(page).to have_selector 'table.index tbody tr', count: 2
    expect(page).to have_text different_division_user.proper_name
  end
  it 'allows filtering different kinds of users' do
    driver = create :user, :driver
    supervisor = create :user, :supervisor
    visit users_url
    expect(page).to have_selector 'table.index tbody tr', count: 3
    click_button 'Drivers'
    expect(page).to have_selector 'table.index tbody tr', count: 1
    expect(page).to have_text driver.proper_name
    click_button 'Supervisors'
    expect(page).to have_selector 'table.index tbody tr', count: 1
    expect(page).to have_text supervisor.proper_name
    click_button 'Staff'
    expect(page).to have_selector 'table.index tbody tr', count: 1
    expect(page).to have_text staff.proper_name
    click_button 'All'
    expect(page).to have_selector 'table.index tbody tr', count: 3
  end
  it 'allows managing inactive users' do
    inactive = create :user, active: false
    visit users_url
    expect(page).to have_text 'Manage inactive users'
    expect(page).not_to have_text inactive.proper_name
    click_on 'Manage inactive users'
    expect(page).to have_selector 'h1', text: 'Inactive Users'
    expect(page.current_url).to end_with users_path(inactive: true)
    expect(page).to have_text inactive.proper_name
    expect(page).not_to have_text staff.proper_name
    click_on 'Manage active users'
    expect(page.current_url).to end_with users_path
    expect(page).to have_selector 'h1', text: 'Active Users'
  end
  context 'with no inactive users' do
    it 'does not allow managing inactive users' do
      visit users_url
      expect(page).not_to have_text 'Manage inactive users'
    end
  end
end
