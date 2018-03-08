# frozen_string_literal: true

require 'spec_helper'

describe 'special incident fields' do
  let(:driver) { create :user, :driver }
  before(:each) { when_current_user_is driver }
  it 'allows filling in collision fields' do
    visit new_incident_path
    expect(page).not_to have_text 'Motor Vehicle Collision Information'
    check 'Did the incident involve a collision?'
    expect(page).to have_text 'Motor Vehicle Collision Information'
  end
  it 'does not require filling in fields for collisions' do
    visit new_incident_path
    fill_in_base_incident_fields
    check 'Did the incident involve a collision?'
    wait_for_animation!
    click_on 'Save report'
    expect(page.current_url).to end_with incident_path(Incident.last, format: :pdf)
  end
  it 'shows collision fields for collision incidents' do
    driver_report = create :incident_report, :driver_report, :with_incident,
      :collision, user: driver
    create :incident, driver_incident_report: driver_report
    expect(driver_report).to be_motor_vehicle_collision
    visit edit_incident_report_url(driver_report)
    expect(page).to have_text 'Motor Vehicle Collision Information'
  end

  it 'allows filling in other vehicle info as necessary' do
    visit new_incident_path
    check 'Did the incident involve a collision?'
    wait_for_animation!
    expect(page).to have_field 'Other vehicle owner name'
    check 'Is the other driver involved the owner of the vehicle?'
    expect(page).not_to have_field 'Other vehicle owner name'
  end
  it 'shows other vehicle owner information as necessary' do
    driver_report = create :incident_report, :driver_report, :with_incident,
      :collision, :other_vehicle_not_driven_by_owner, user: driver
    create :incident, driver_incident_report: driver_report
    expect(driver_report).not_to be_other_vehicle_owned_by_other_driver
    visit edit_incident_report_url(driver_report)
    expect(page).to have_field 'Other vehicle owner name'
  end

  it 'allows filling in police info' do
    visit new_incident_path
    check 'Did the incident involve a collision?'
    wait_for_animation!
    expect(page).not_to have_field 'Police badge number'
    check 'Did police respond to the incident?'
    wait_for_animation!
    expect(page).to have_field 'Police badge number'
  end
  it 'does not require police info' do
    visit new_incident_path
    fill_in_base_incident_fields
    check 'Did the incident involve a collision?'
    wait_for_animation!
    check 'Did police respond to the incident?'
    click_on 'Save report'
    expect(page.current_url).to end_with incident_path(Incident.last, format: :pdf)
  end
  it 'shows police fields as necessary' do
    driver_report = create :incident_report, :driver_report, :with_incident,
      :collision, :police_on_scene, user: driver
    create :incident, driver_incident_report: driver_report
    expect(driver_report).to be_police_on_scene
    visit edit_incident_report_url(driver_report)
    expect(page).to have_field 'Police badge number'
  end

  it 'allows filling in passenger incident fields' do
    visit new_incident_path
    expect(page).not_to have_text 'Passenger Incident Information'
    check 'Did the incident involve a passenger?'
    expect(page).to have_text 'Passenger Incident Information'
  end
  it 'does not require filling in passenger incident fields' do
    visit new_incident_path
    fill_in_base_incident_fields
    check 'Did the incident involve a passenger?'
    wait_for_animation!
    expect(page).to have_text 'Passenger Incident Information'
    click_on 'Save report'
    expect(page.current_url).to end_with incident_path(Incident.last, format: :pdf)
  end
  it 'shows passenger fields for passenger incidents' do
    driver_report = create :incident_report, :driver_report, :with_incident, 
      :passenger_incident, user: driver
    expect(driver_report).to be_passenger_incident
    visit edit_incident_report_url(driver_report)
    expect(page).to have_text 'Passenger Incident Information'
  end

  it 'allows filling in reason bus was not up to curb' do
    visit new_incident_path
    check 'Did the incident involve a passenger?'
    expect(page).not_to have_field 'Reason not up to curb'
    select 'Stopped', from: 'Motion of bus'
    uncheck 'Was the bus pulled completely up to the curb?'
    expect(page).to have_field 'Reason not up to curb'
  end
  it 'does not require filling in reason not up to curb' do
    visit new_incident_path
    fill_in_base_incident_fields
    check 'Did the incident involve a passenger?'
    select 'Stopped', from: 'Motion of bus'
    uncheck 'Was the bus pulled completely up to the curb?'
    click_on 'Save report'
    expect(page.current_url).to end_with incident_path(Incident.last, format: :pdf)
  end
  it 'shows reason not up to curb field as necessary' do
    driver_report = create :incident_report, :driver_report, :with_incident,
      :passenger_incident, :not_up_to_curb, user: driver
    expect(driver_report).to be_needs_reason_not_up_to_curb
    visit edit_incident_report_url(driver_report)
    expect(page).to have_field 'Reason not up to curb'
  end
end
