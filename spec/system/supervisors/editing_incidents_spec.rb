# frozen_string_literal: true

require 'spec_helper'

describe 'editing incidents as a supervisor' do
  let(:supervisor) { create :user, :supervisor }
  before(:each) { when_current_user_is supervisor }
  let(:report) { create :incident_report, user: supervisor }
  let(:incident) { create :incident, supervisor_incident_report: report }
  it "says you're editing a supervisor report" do
    visit edit_incident_report_url(incident.supervisor_incident_report)
    expect(page).to have_text 'Editing Supervisor Account of Incident'
  end
end
