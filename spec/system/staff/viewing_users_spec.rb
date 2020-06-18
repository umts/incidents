# frozen_string_literal: true

require 'spec_helper'

describe 'viewing users as staff', js: true do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  context 'with active users' do
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
    context 'with different kinds of users' do
      let!(:driver) { create :user, :driver }
      let!(:supervisor) { create :user, :supervisor }
      before :each do
        visit users_url
      end
      it "allows viewing a driver's incidents" do
        visit users_url
        expect(page).to have_selector 'button',
          text: 'View incidents', count: 1
        click_button 'View incidents'
        expect(page.current_url).to end_with incidents_user_path(driver)
        expect(page).to have_content 'No incidents found.'
        expect(page).to have_selector 'h1',
          text: "#{driver.full_name}'s Incidents"
      end
      it 'allows filtering by drivers' do
        expect(page).to have_selector 'table.index tbody tr', count: 3
        click_button 'Drivers'
        expect(page).to have_selector 'table.index tbody tr', count: 1
        expect(page).to have_text driver.proper_name
      end
      it 'allows filtering by supervisors' do
        click_button 'Supervisors'
        expect(page).to have_selector 'table.index tbody tr', count: 1
        expect(page).to have_text supervisor.proper_name
      end
      it 'allows filtering by staff' do
        click_button 'Staff'
        expect(page).to have_selector 'table.index tbody tr', count: 1
        expect(page).to have_text staff.proper_name
      end
      it 'allows filtering by all' do
        click_button 'All'
        expect(page).to have_selector 'table.index tbody tr', count: 3
      end
    end
  end
  context 'with inactive users' do
    let!(:inactive) { create :user, active: false }
    it 'allows managing inactive users' do
      visit users_url
      expect(page).to have_text 'Manage inactive users'
      expect(page).not_to have_text inactive.proper_name
      click_on 'Manage inactive users'
      expect(page).to have_text inactive.proper_name
      expect(page).not_to have_text staff.proper_name
    end
    it 'allows user to go between inactive and active' do
      visit users_url
      click_on 'Manage inactive users'
      expect(page.current_url).to end_with users_path(inactive: true)
      expect(page).to have_selector 'h1', text: 'Inactive Users'
      click_on 'Manage active users'
      expect(page.current_url).to end_with users_path
      expect(page).to have_selector 'h1', text: 'Active Users'
    end
  end
  context 'with no inactive users' do
    it 'does not allow managing inactive users' do
      visit users_url
      expect(page).not_to have_text 'Manage inactive users'
    end
  end
end
