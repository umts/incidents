# frozen_string_literal: true

require 'spec_helper'

describe 'creating incidents as a supervisor' do
  let(:user) { create :user, :supervisor }
  let!(:driver_in_division) { create :user, :driver, divisions: user.divisions }
  before(:each) { when_current_user_is user }
  it 'asks you to pick a driver' do
    visit incidents_url
    find('button', text: 'New Incident').click
    expect(page).to have_css 'h1', text: 'New Incident'
    expect(page).to have_select 'Driver'
  end
  it 'selects you by default' do
    visit new_incident_url
    expect(page).to have_select 'Supervisor', selected: user.proper_name
  end
  it 'allows you to select other drivers from your division' do
    create :user, :driver # will be in different division
    visit new_incident_url
    # options only passes if the complete set matches
    expect(page).to have_select 'Driver', options: ['', driver_in_division.proper_name]
  end
  it 'allows you to select other supervisors from your division' do
    create :user, :supervisor # will be in different division
    visit new_incident_url
    expect(page).to have_select 'Supervisor', options: ['', user.proper_name]
  end
end
