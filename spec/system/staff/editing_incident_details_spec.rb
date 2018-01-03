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
end
