# frozen_string_literal: true

require 'spec_helper'

describe 'deleting incidents as staff', js: true  do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let!(:incident) { incident_in_divisions(staff.divisions) }
  it 'allows deleting incidents' do
    visit incidents_url
    expect(page).to have_selector 'table.incidents tbody tr', count: 1
    click_button 'Delete'
    expect(page).to have_selector 'p.notice',
      text: 'Incident was successfully deleted.'
    expect(page).not_to have_selector 'table.incidents tbody tr'
  end
end
