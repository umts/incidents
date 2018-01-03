# frozen_string_literal: true

require 'spec_helper'

describe 'viewing incident report history as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let(:incident) { incident_in_divisions(staff.divisions) }
  it 'allows viewing incident history' do
    visit incident_url(incident)
    within('.driver-incident-report') { click_on 'View full history' }
    expect(page.current_url).to end_with history_incident_report_path(incident.driver_incident_report)
  end
end
