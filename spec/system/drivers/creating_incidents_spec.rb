# frozen_string_literal: true

require 'spec_helper'

describe 'creating incidents as a driver' do
  before(:each) { when_current_user_is :driver }
  let :new_incident do
    visit new_incident_url
    fill_in_date_and_time
    click_on 'Create Incident Report'
  end
  it 'prompts to input the date before redirecting to driver report', js: true do
    visit incidents_url
    find('button', text: 'New Incident').click
    expect(page).to have_text 'New Incident'
    click_on 'Create Incident Report'
    expect(page).to have_text "Date and time of incident can't be blank"
    fill_in_date_and_time
    click_on 'Create Incident Report'
    expect(page).to have_text 'Editing Driver Account of Incident'
    driver_report = Incident.last.driver_incident_report
    expect(page.current_url).to end_with edit_incident_report_path(driver_report)
  end


  it 'requires base fields', js: true do
    new_incident
    save_and_preview

    expect(page).to have_text 'This incident report has 5 missing values and so cannot be marked as completed.'
    expect(page).to have_text "Location can't be blank"
    expect(page).to have_text "Town can't be blank"
    expect(page).to have_text "Bus # can't be blank"
    expect(page).to have_text "Direction bus was travelling can't be blank"
    expect(page).to have_text "Describe the incident in detail. can't be blank"
  end

  it 'only requires bus, location, and town', js: true do
    new_incident
    fill_in_base_incident_fields
    save_and_preview

    expect(page).not_to have_text('cannot be marked as completed')
  end
end
