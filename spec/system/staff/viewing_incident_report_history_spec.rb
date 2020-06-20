# frozen_string_literal: true

require 'spec_helper'

describe 'viewing incident report history as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let(:incident) { incident_in_divisions(staff.divisions) }
  it 'allows viewing incident history', js: true do
    visit incident_url(incident)
    within('.driver-incident-report') { click_on 'View full history' }
    expect(page.current_url).to end_with history_incident_report_path(incident.driver_incident_report)
  end
  it 'allows viewing supervisor report history', js: true do
    visit incident_url(incident)
    within('.supervisor-report') { click_on 'View full history' }
    expect(page.current_url).to end_with history_supervisor_report_path(incident.supervisor_report)
  end
end

