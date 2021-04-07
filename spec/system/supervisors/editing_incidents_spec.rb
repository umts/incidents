# frozen_string_literal: true

require 'spec_helper'

describe 'editing incidents as a supervisor' do
  before :each do
    @supervisor = create :user, :supervisor
    when_current_user_is @supervisor
    @report = create :incident_report, user: @supervisor
    @incident = create :incident, supervisor_incident_report: @report
    @incident.supervisor_report.assign_attributes(
      test_status: 'Post Accident: No threshold met (no drug test)',
      reason_threshold_not_met: nil
    )
    @incident.supervisor_report.save(validate: false)
  end
  it "says you're editing a supervisor account of incident" do
    visit edit_incident_report_path(@incident.supervisor_incident_report)
    expect(page).to have_text 'Editing Supervisor Account of Incident'
  end
  it 'puts you into the supervisor report if it needs completing' do
    visit edit_incident_report_path(@incident.supervisor_incident_report)
    fill_in_base_incident_fields
    click_button 'Save report'
    expect(page).to have_selector 'p.notice',
                                  text: 'Incident report was successfully saved. Please complete the supervisor report.'
  end
  context 'admin deletes the incident' do
    it 'displays a nice error message' do
      visit edit_incident_report_path(@incident.supervisor_incident_report)
      expect(page).to have_content 'Editing Supervisor Account of Incident'
      @incident.destroy
      click_button 'Save report'
      expect(page).to have_selector 'p.notice', text: 'This incident report no longer exists.'
    end
  end
end
