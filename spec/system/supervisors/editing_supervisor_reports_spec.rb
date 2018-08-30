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
      incident.destroy
      click_button 'Save supervisor report'
      wait_for_ajax!
      expect(response.status).to eq 500
    end
  end
end
