# frozen_string_literal: true

require 'spec_helper'

describe 'editing incidents as a driver' do
  let(:driver) { create :user, :driver }
  before(:each) { when_current_user_is driver }
  let(:report) { create :incident_report, :driver_report, user: driver }
  let!(:incident) { create :incident, driver_incident_report: report }
  context 'admin deletes the incident' do
    it 'displays a nice error message' do
      visit incidents_url
      expect(page).to have_selector 'table.incidents tbody tr', count: 1
      within 'tr', text: driver.proper_name do
        click_button 'Edit'
      end
      expect(page).to have_content 'Editing Driver Account of Incident'
      incident.destroy
      click_button 'Save report'
      wait_for_ajax!
      expect(page).to have_selector 'p.notice',
                                    text: 'This incident report no longer exists.'
    end
  end
  context 'adding multiple injured passengers' do
    it 'displays all of them' do
      visit incidents_url
      expect(page).to have_selector 'table.incidents tbody tr', count: 1
      within 'tr', text: driver.proper_name do
        click_button 'Edit'
      end
      check 'Did the incident involve a passenger?'
      expect(page).to have_text 'Passenger Incident Information'
      within first('div', text: 'Passenger Incident Information') do
        # unable to check 'Were passengers injured?'
        page.find('#supervisor_report_inj_pax_info').click
        fill_in 'Name', with: 'Ben'
        fill_in 'Nature of injury', with: 'Slipped on banana'
        click_button 'Add injured passenger info'
        second_field = all('.pax-fields')[1]
        within second_field do
          fill_in 'Name', with: 'Emily'
          fill_in 'Nature of injury', with: 'Slipped on many bananas'
        end
      end
      click_button 'Save report'

      visit incident_url(incident)
      expect(page).to have_selector 'h2', text: 'Driver Incident Report'
      expect(page).to have_selector 'h3', text: 'Passenger Incident Information'
      expect(page).to have_text 'Injured Passenger Information'
      expect(page).to have_selector 'li',
                                    text: 'Ben; Slipped on banana; Not transported to hospital by ambulance'
      expect(page).to have_selector 'li',
                                    text: 'Emily; Slipped on many bananas; Not transported to hospital by ambulance'
    end
  end
  context 'deleting an injured passenger' do
    it 'displays the current injured passengers' do
      pax = create :injured_passenger, incident_report: report
      pax2 = create :injured_passenger, incident_report: report
      visit incidents_url
      expect(page).to have_selector 'table.incidents tbody tr', count: 1
      within 'tr', text: driver.proper_name do
        click_button 'Edit'
      end
      check 'Did the incident involve a passenger?'
      click_button 'Delete injured passenger info'
      click_button 'Save report'

      visit incident_url(incident)
      expect(page).to have_selector 'h2', text: 'Driver Incident Report'
      expect(page).to have_selector 'h3', text: 'Passenger Incident Information'
      expect(page).to have_text 'Injured Passenger Information'
      expect(page).to have_selector 'li', count: 1
    end
  end
end
