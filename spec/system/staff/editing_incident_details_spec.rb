# frozen_string_literal: true

require 'spec_helper'

describe 'editing incident details as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let(:incident) { incident_in_divisions staff.divisions }
  it 'allows editing reason codes', js: true  do
    create :reason_code, identifier: 'A-1', description: 'Falling bananas'
    create :supplementary_reason_code, identifier: 'a-8', description: 'Miscellaneous'
    visit edit_incident_url(incident)
    select 'A-1: Falling bananas', from: 'Reason code'
    click_button 'Save incident details'
    wait_for_ajax!
    expect(page).to have_selector 'p.notice',
      text: 'Incident report was successfully saved.'
  end
  it 'requires reason codes, latlong, and root cause analysis for completed incidents', js: true  do
    create :reason_code, identifier: 'A-1', description: 'Falling bananas'
    create :supplementary_reason_code, identifier: 'a-8', description: 'Miscellaneous'
    visit edit_incident_url(incident)
    check 'Completed'
    select '', from: 'Reason code'
    click_button 'Save incident details'
    wait_for_ajax!
    expect(page).to have_text 'This incident has 5 missing values and so cannot be marked as completed.'
    expect(page).to have_text "Reason code can't be blank"
    expect(page).to have_text "Supplementary reason code can't be blank"
    expect(page).to have_text "Root cause analysis can't be blank"
    expect(page).to have_text "Latitude can't be blank"
    expect(page).to have_text "Longitude can't be blank"
    select 'A-1: Falling bananas', from: 'Reason code'
    select 'a-8: Miscellaneous', from: 'Supplementary reason code'
    fill_in 'Root cause analysis', with: 'Lorem ipsum dolor sit amet.'
    fill_in 'Latitude', with: '42.105552'
    fill_in 'Longitude', with: '-72.596511'
    click_button 'Save incident details'
    wait_for_ajax!
    expect(page).to have_selector 'p.notice',
      text: 'Incident report was successfully saved.'
  end
end
