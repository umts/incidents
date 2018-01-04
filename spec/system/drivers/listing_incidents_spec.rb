# frozen_string_literal: true

require 'spec_helper'

describe 'listing incidents as a driver' do
  let(:driver) { create :user, :driver }
  before(:each) { when_current_user_is driver }

  it 'shows any incomplete incidents for the driver' do
    driver_report = create :incident_report, :incomplete, user_id: driver.id
    incident = build :incident, driver_incident_report: driver_report
    # Validations don't pass for incomplete incidents. They do in real life,
    # but they don't because we create objects in reverse order here.
    incident.save validate: false
    visit root_url
    expect(page).to have_link 'View', href: incident_path(incident)
  end
  it 'does not show any complete incidents for the driver' do
    driver_report = create :incident_report, user_id: driver.id
    create :incident, :completed, driver_incident_report: driver_report
    visit incidents_url
    expect(page).not_to have_link 'View'
    expect(page).to have_text 'You have no incident reports that need attention.'
  end
  it 'does not show any incomplete incidents for other drivers' do
    driver_report = create :incident_report, :driver_report, :incomplete
    incident = build :incident, driver_incident_report: driver_report
    # Validations don't pass for incomplete incidents. They do in real life,
    # but they don't because we create objects in reverse order here.
    incident.save validate: false
    visit incidents_url
    expect(page).not_to have_link 'View'
    expect(page).to have_text 'You have no incident reports that need attention.'
  end
  it 'does not allow listing unclaimed incidents' do
    create :incident, :unclaimed
    visit incidents_url
    expect(page).not_to have_link 'Unclaimed Incidents 1'
  end
end
