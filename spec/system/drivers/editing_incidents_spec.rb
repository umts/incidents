# frozen_string_literal: true

require 'spec_helper'

describe 'editing incidents as a driver' do
  let(:driver) { create :user, :driver}
  before(:each){ when_current_user_is driver }
  let(:report) { create :incident_report, user: driver }
  let(:incident) { create :incident, incident_report: report }
  context 'admin deletes the incident' do
    it 'displays a nice error message' do
      visit edit_incident_url(incident)
      incident.destroy
      click_button 'Save report'
      wait_for_ajax!
      expect(response.status).to eq 500
    end
  end
end
