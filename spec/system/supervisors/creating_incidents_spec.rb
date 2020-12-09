# frozen_string_literal: true

require 'spec_helper'

describe 'creating incidents as a supervisor' do
  let(:user) { create :user, :supervisor }
  let!(:driver_in_division) { create :user, :driver, divisions: user.divisions }
  before(:each) { when_current_user_is user }
  it 'asks you to pick a driver', js: true do
    visit incidents_url
    find('button', text: 'New Incident').click
    expect(page).to have_css 'h1', text: 'New Incident'
    expect(page).to have_select 'Driver'
  end
  it 'asks you to enter date and time of incident' do
    visit new_incident_url
    expect(page).to have_select 'Year'
  end
  it 'selects you by default' do
    visit new_incident_url
    expect(page).to have_select 'Supervisor', selected: user.proper_name
  end
  it 'allows you to select other supervisors from your division' do
    create :user, :supervisor # will be in different division
    visit new_incident_url
    expect(page).to have_select 'Supervisor', options: ['', user.proper_name]
  end
  it 'does not send you directly to fill in the report after creating it' do
    visit new_incident_url
    select driver_in_division.proper_name, from: 'Driver'
    fill_in_date_and_time
    select user.proper_name, from: 'Supervisor'
    click_on 'Create Incident Report'
    expect(page.current_url).to end_with incidents_path
  end
  it 'tells you that the report has been created successfully' do
    visit new_incident_url
    select driver_in_division.proper_name, from: 'Driver'
    fill_in_date_and_time
    select user.proper_name, from: 'Supervisor'
    click_on 'Create Incident Report'
    expect(page).to have_text 'Incident was successfully created.'
  end
  it 'shows you new incident in table' do
    visit new_incident_url
    select driver_in_division.proper_name, from: 'Driver'
    fill_in_date_and_time
    select user.proper_name, from: 'Supervisor'
    click_on 'Create Incident Report'
    expect(page).to have_selector 'table.incidents tbody tr', count: 1
  end
  context 'without selecting a supervisor' do
    it 'creates a supervisor-less report' do
      visit new_incident_url
      select driver_in_division.proper_name, from: 'Driver'
      fill_in_date_and_time
      select '', from: 'Supervisor'
      click_on 'Create Incident Report'
      expect(page).to have_text 'Incident was successfully created.'
    end
  end
  context 'without selecting a driver' do
    it 'does not create an incident' do
      visit new_incident_url
      select '', from: 'Driver'
      fill_in_date_and_time
      select user.proper_name, from: 'Supervisor'
      click_on 'Create Incident Report'
      expect(page).not_to have_text 'Incident was successfully created.'
      expect(page).to have_text 'Driver must exist'
    end
  end
  context 'without selecting incident date and time' do
    it 'does not create an incident' do
      visit new_incident_url
      click_on 'Create Incident Report'
      expect(page).not_to have_text 'Incident was successfully created.'
      expect(page).to have_text "Date and time of incident can't be blank"
    end
  end
end
