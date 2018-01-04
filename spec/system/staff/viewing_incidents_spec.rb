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

  context 'with incomplete incidents' do
    let!(:incident) { incident_in_divisions staff.divisions, completed: false }
    it 'allows viewing incomplete incidents' do
      visit incidents_url
      click_button 'Incomplete Incidents 1'
      expect(page.current_url).to end_with incomplete_incidents_path
    end
  end
  context 'with no incomplete incidents' do
    it "tells you there aren't any" do
      visit incomplete_incidents_url
      expect(page).to have_selector 'p.notice',
        text: 'No incomplete incidents.'
      expect(page.current_url).to end_with incidents_path
    end
  end

  context 'with unclaimed incidents' do
    let!(:incident) { incident_in_divisions staff.divisions, :unclaimed }
    it 'allows viewing unclaimed incidents' do
      visit incidents_url
      click_button 'Unclaimed Incidents 1'
      expect(page.current_url).to end_with unclaimed_incidents_path
    end
  end
  context 'with no unclaimed incidents' do
    it "tells you there aren't any" do
      visit unclaimed_incidents_url
      expect(page).to have_selector 'p.notice',
        text: 'No unclaimed incidents.'
      expect(page.current_url).to end_with incidents_path
    end
  end
end
