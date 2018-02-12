# frozen_string_literal: true

require 'spec_helper'

describe 'editing incidents as a supervisor' do
  let(:supervisor) { create :user, :supervisor }
  before(:each) { when_current_user_is supervisor }
  let(:report) { create :incident_report, user: supervisor }
  let :incident do
    create :incident, supervisor_incident_report: report,
      supervisor_report: SupervisorReport.new
  end
  it "says you're editing a supervisor account of incident" do
    visit edit_incident_report_url(incident.supervisor_incident_report)
    expect(page).to have_text 'Editing Supervisor Account of Incident'
  end
  it 'puts you into the supervisor report if it needs completing' do
    visit edit_incident_report_url(incident.supervisor_incident_report)
    fill_in_base_incident_fields
    click_button 'Save report'
    expect(page).to have_selector 'p.notice',
      text: 'Incident report was successfully saved. Please complete the supervisor report.'
  end
end
