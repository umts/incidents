# frozen_string_literal: true

require 'spec_helper'

describe 'listing incidents as a supervisor' do
  let(:supervisor) { create :user, :supervisor }
  before(:each) { when_current_user_is supervisor }

  it 'shows any incomplete incidents for the supervisor' do
    supervisor_report = create :incident_report, :incomplete, user_id: supervisor.id
    incident = build :incident, supervisor_incident_report: supervisor_report
    # Validations don't pass for incomplete incidents. They do in real life,
    # but they don't because we create objects in reverse order here.
    incident.save validate: false
    visit incidents_url
    expect(page).to have_link 'View', href: incident_path(incident)
  end
  it 'does not show any complete incidents for the supervisor' do
    supervisor_report = create :incident_report, user_id: supervisor.id
    create :incident, :completed, supervisor_incident_report: supervisor_report
    visit incidents_url
    expect(page).not_to have_link 'View'
    expect(page).to have_text 'You have no incident reports that need attention.'
  end
  it 'does not show incomplete incidents for other supervisors' do
    supervisor_report = create :incident_report, :incomplete
    incident = build :incident, supervisor_incident_report: supervisor_report
    # Validations don't pass for incomplete incidents. They do in real life,
    # but they don't because we create objects in reverse order here.
    incident.save validate: false
    visit incidents_url
    expect(page).not_to have_link 'View'
    expect(page).to have_text 'You have no incident reports that need attention.'
  end
  it 'allows listing unclaimed incidents' do
    driver = create :user, :driver, divisions: supervisor.divisions
    driver_report = create :incident_report, :driver_report, user_id: driver.id
    create :incident, :unclaimed, driver_incident_report: driver_report
    visit incidents_url
    expect(page).to have_link 'Unclaimed Incidents 1'
  end
end
