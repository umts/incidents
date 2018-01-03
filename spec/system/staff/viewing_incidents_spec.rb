# frozen_string_literal: true

require 'spec_helper'

describe 'viewing incidents as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  context 'searching by claim number' do
    it 'allows searching for incidents by claim number' do
      incident = incident_in_divisions(staff.divisions, claim_number: 'apples')
      incident = incident_in_divisions(staff.divisions, claim_number: 'bananas')
      visit incidents_url
      expect(page).to have_selector 'table.incidents tbody tr', count: 2
      fill_in 'Search by claim number', with: 'bananas'
      click_button 'Search'
      # just the bananas
      expect(page).to have_selector 'table.incidents tbody tr', count: 1
    end
  end

  context 'with an injured passenger transported to hospital' do
    it 'displays this' do
      pax = create :injured_passenger, transported_to_hospital: true
      incident = create :incident, supervisor_report: pax.supervisor_report
      visit incident_url(incident)
      expect(page).to have_text 'Transported to hospital'
    end
  end
  context 'with an injured passenger not transported to hospital' do
    it 'displays this' do
      pax = create :injured_passenger, transported_to_hospital: false
      incident = create :incident, supervisor_report: pax.supervisor_report
      visit incident_url(incident)
      expect(page).to have_text 'Not transported to hospital'
    end
  end
end
