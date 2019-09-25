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
  it 'requires base fields' do
    visit new_incident_url
    click_on 'Save report'
    expect(page).to have_text 'This incident report has 6 missing values and so cannot be marked as completed.'
    expect(page).to have_text "Date and time of incident can't be blank"
    expect(page).to have_text "Location can't be blank"
    expect(page).to have_text "Town can't be blank"
    expect(page).to have_text "Bus # can't be blank"
    expect(page).to have_text "Direction bus was travelling can't be blank"
    expect(page).to have_text "Describe the incident in detail. can't be blank"
  end
  it 'only requires bus, location, and town' do
    visit new_incident_url
    fill_in_base_incident_fields
    click_on 'Save report'

    expect(page).not_to have_text('cannot be marked as completed')
  end
end
