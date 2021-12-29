# frozen_string_literal: true

require 'spec_helper'

describe 'editing incidents as a supervisor' do
  let(:supervisor) { create :user, :supervisor }
  let(:report) { build :incident_report, user: supervisor }
  let(:supervisor_report) { build :supervisor_report, :with_test_status }
  let(:incident) { create :incident, supervisor_incident_report: report, supervisor_report: supervisor_report }

  before do
    when_current_user_is supervisor
    visit edit_incident_report_path(incident.supervisor_incident_report)
  end

  it "says you're editing a supervisor account of incident" do
    expect(page).to have_text 'Editing Supervisor Account of Incident'
  end

  context 'when you somehow skip validations' do
    before do
      supervisor_report.assign_attributes(amplifying_comments: nil)
      supervisor_report.save(validate: false)
    end

    it 'puts you into the supervisor report if it needs completing' do
      fill_in_base_incident_fields
      click_button 'Save report'
      expect(page).to have_selector 'p.notice',
                                    text: 'Incident report was successfully saved. Please complete the supervisor report.'
    end
  end

  context 'when an admin deletes the incident' do
    it 'displays a nice error message' do
      expect(page).to have_content 'Editing Supervisor Account of Incident'
      incident.destroy
      click_button 'Save report'
      expect(page).to have_selector 'p.notice', text: 'This incident report no longer exists.'
    end
  end
end
