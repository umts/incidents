# frozen_string_literal: true

require 'spec_helper'

describe 'viewing incident report history as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let(:incident) { incident_in_divisions(staff.divisions) }
  it 'allows viewing incident history' do
    visit incident_path(incident)
    within('.driver-incident-report') { click_on 'View full history' }
    expect(page).to have_current_path history_incident_report_path(incident.driver_incident_report)
  end
  it 'allows viewing supervisor report history' do
    visit incident_path(incident)
    within('.supervisor-report') { click_on 'View full history' }
    expect(page).to have_current_path history_supervisor_report_path(incident.supervisor_report)
  end
end
