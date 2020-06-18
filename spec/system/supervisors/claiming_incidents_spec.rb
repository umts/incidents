# frozen_string_literal: true

require 'spec_helper'

describe 'claiming incidents as a supervisor', js: true do
  let(:incident) { create :incident, :unclaimed }
  let(:supervisor) { create :user, :supervisor, divisions: incident.driver.divisions }
  before(:each) { when_current_user_is supervisor }
  it 'allows claiming incidents' do
    visit root_url
    click_button 'Unclaimed Incidents 1'
    click_button 'Claim'
    wait_for_ajax!
    expect(page).to have_selector 'p.notice',
      text: 'You have claimed this incident. Please complete the supervisor report'
    expect(page).to have_selector 'table.incidents tbody tr', count: 1
  end
end
