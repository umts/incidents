# frozen_string_literal: true

require 'spec_helper'

describe 'editing incident details as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let(:incident) { incident_in_divisions staff.divisions }
  it 'allows editing reason codes' do
    create :reason_code, identifier: 'A-1', description: 'Falling bananas'
    visit edit_incident_url(incident)
    select 'A-1: Falling bananas', from: 'Reason code'
    click_button 'Save incident details'
    wait_for_ajax!
    expect(page).to have_selector 'p.notice',
      text: 'Incident report was successfully saved.'
  end
  it 'requires reason codes and root cause analysis for completed incidents' do
    create :reason_code, identifier: 'A-1', description: 'Falling bananas'
    visit edit_incident_url(incident)
    check 'Completed'
    select '', from: 'Reason code'
    click_button 'Save incident details'
    wait_for_ajax!
    expect(page).to have_text 'This incident has 3 missing values and so cannot be marked as completed.'
    expect(page).to have_text "Reason code can't be blank"
    expect(page).to have_text "Second reason code can't be blank"
    expect(page).to have_text "Root cause analysis can't be blank"
    select 'A-1: Falling bananas', from: 'Reason code'
    select 'a-8: Miscellaneous', from: 'Second reason code'
    fill_in 'Root cause analysis', with: 'Lorem ipsum dolor sit amet.'
    click_button 'Save incident details'
    wait_for_ajax!
    expect(page).to have_selector 'p.notice',
      text: 'Incident report was successfully saved.'
  end
end
