# frozen_string_literal: true

require 'spec_helper'

describe 'viewing incident XML as a staff member' do
  before(:each) { when_current_user_is :staff }
  let(:incident) { create :incident }
  it 'allows viewing incident XML' do
    visit incident_url(incident)
    click_on 'Export File'
    expect(page.current_url).to end_with incident_path(incident, format: :xml)
  end
  context 'with motor vehicle collisions' do
    let(:driver_report) { create :incident_report, :driver_report, :collision }
    let(:incident) { create :incident, driver_incident_report: driver_report }
    it 'works' do
      visit incident_url(incident, format: :xml)
      expect(page.current_url).to end_with incident_path(incident, format: :xml)
    end
  end
end

describe 'viewing incident XML as a driver' do
  let(:incident) { create :incident }
  it "you can't" do
    when_current_user_is :driver
    visit incident_url(incident, format: :xml)
    expect(page).to have_text 'You do not have permission to access this page.'
  end
end
