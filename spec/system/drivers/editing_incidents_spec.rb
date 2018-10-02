# frozen_string_literal: true

require 'spec_helper'

describe 'editing incidents as a driver' do
  let(:driver) { create :user, :driver }
  before(:each) { when_current_user_is driver }
  let(:report) { create :incident_report, :driver_report, user: driver }
  let!(:incident) { create :incident, driver_incident_report: report }
  before :each do
    visit incidents_url
    expect(page).to have_selector 'table.incidents tbody tr', count: 1
    within 'tr', text: driver.proper_name do
      click_button 'Edit'
    end
  end
  context 'admin deletes the incident' do
    it 'displays a nice error message' do
      expect(page).to have_content 'Editing Driver Account of Incident'
      incident.destroy
      click_button 'Save report'
      wait_for_ajax!
      expect(page).to have_selector 'p.notice', text: 'This incident report no longer exists.'
    end
  end
  context 'adding multiple injured passengers' do
    it 'displays all of them' do
      check 'Did the incident involve a passenger?'
      expect(page).to have_text 'Passenger Incident Information'
      check 'Were passengers injured?'
      
      fill_in 'Name', with: 'Ben'
      fill_in 'Nature of injury', with: 'Slipped on banana'
      click 'Add injured passenger info'
      fill_in 'Name', with: 'Emily'
      fill_in 'Nature of injury', with: 'Slipped on many bananas'
      click_button 'Save report'
      wait_for_ajax!

      visit incident_url(incident)
      expect(page).to have_text 'Ben'
      expect(page).to have_text 'Emily'
    end
  end
end
