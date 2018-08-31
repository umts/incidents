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
      incident.destroy
      click_button 'Save report'
      wait_for_ajax!
      expect(response.status).to eq 500
    end
  end
end
