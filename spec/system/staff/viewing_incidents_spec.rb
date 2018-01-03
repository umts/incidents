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
end
