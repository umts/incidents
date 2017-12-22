# frozen_string_literal: true

require 'spec_helper'

describe 'creating incidents as a driver' do
  before(:each) { when_current_user_is :driver }
  it 'brings drivers directly to the form' do
    visit incidents_url
    find('button', text: 'New Incident').click
    expect(page).to have_text 'Editing Driver Account of Incident'
    driver_report = Incident.last.driver_incident_report
    expect(page.current_url).to end_with edit_incident_report_path(driver_report)
  end
end

def fill_in_base_incident_fields
  fill_in 'Bus #', with: '1803'
  fill_in 'Location', with: 'Mill and Locust'
  select 'Springfield', from: 'Town'
end
