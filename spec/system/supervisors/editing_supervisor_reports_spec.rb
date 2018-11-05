# frozen_string_literal: true

require 'spec_helper'

describe 'editing supervisor reports as a supervisor' do
  let(:incident) { create :incident }
  let(:supervisor) { incident.supervisor }
  before(:each) { when_current_user_is supervisor }
  it 'allows editing supervisor reports' do
    visit edit_incident_url(incident)
    click_on 'Edit Supervisor Report'
    expect(page.current_url).to end_with edit_supervisor_report_path(incident.supervisor_report)
    check 'Were pictures taken?'
    sleep 0.5 # animation time
    fill_in 'Number of pictures saved', with: 37
    click_button 'Save supervisor report'
    wait_for_ajax!
    expect(page).to have_selector 'p.notice', text: 'Incident report was successfully saved.'
    expect(page).to have_text 'Number of pictures saved: 37'
  end
  context 'admin deletes the incident' do
    it 'displays a nice error message' do
      visit edit_incident_url(incident)
      click_on 'Edit Supervisor Report'
      expect(page).to have_content 'Editing Supervisor Report'
      incident.destroy
      click_button 'Save supervisor report'
      wait_for_ajax!
      expect(page).to have_selector 'p.notice', text: 'This incident report no longer exists.'
    end
  end
  # this test fails because the second_field is disabled...?
  context 'adding multiple witnesses' do
    it 'displays all of them' do
      # there is one witness filled in otherwise
      incident.supervisor_report.witnesses = []
      visit edit_incident_url(incident)
      click_on 'Edit Supervisor Report'
      expect(page).to have_content 'Editing Supervisor Report'
      check 'Were there witnesses?'
      expect(page).to have_text 'Witness Information'
      fill_in 'Name', with: 'Adam'
      fill_in 'Address', with: '255 Governors Dr, Amherst'
      click_button 'Add witness info'
      second_field = all('.witness-fields')[1]
      within second_field do
        fill_in 'Name', with: 'Karin'
        fill_in 'Address', with: '51 Forestry Way, Amherst'
      end
      click_button 'Save supervisor report'

      visit incident_url(incident)
      expect(page).to have_selector 'h2', text: 'Supervisor Incident Report'
      expect(page).to have_selector 'h3', text: 'Witness Information'
      expect(page).to have_selector 'li',
                                    text: 'Adam; 355 Governors Dr, Amherst'
      expect(page).to have_selector 'li',
                                    text: 'Karin; 51 Forestry Way, Amherst'
    end
  end
  context 'deleting a witness' do
    it 'displays the current witnesses' do
    end
  end
end
