# frozen_string_literal: true

require 'spec_helper'

describe 'deleting users as staff' do
  before(:each) { when_current_user_is :staff }
  let!(:user) { create :user, :driver }
  context 'user has no incidents' do
    it 'allows deleting the user' do
      visit users_url
      click_button 'Drivers'
      expect(page).to have_selector 'button',
        text: 'Delete', count: 1
      click_button 'Delete'
      wait_for_ajax!
      expect(page).to have_selector 'p.notice',
        text: 'User was deleted successfully.'
      # Just the current user should be left.
      expect(page).to have_selector 'table.index tbody tr', count: 1
    end
  end
  context 'user has incidents' do
    it 'does not allow deleting the user' do
      # Don't create supervisor things so that a supervisor isn't created.
      create :incident,
        driver_incident_report: create(:incident_report, user: user),
        supervisor_incident_report: nil, supervisor_report: nil
      visit users_url
      click_button 'Drivers'
      expect(page).to have_selector 'button',
        text: 'Delete', count: 1
      click_button 'Delete'
      wait_for_ajax!
      expect(page).to have_selector 'p.alert',
        text: 'Cannot delete users who have incidents in their name.'
      # Should be the current user plus the undeleted user.
      expect(page).to have_selector 'table.index tbody tr', count: 2
    end
  end
end
