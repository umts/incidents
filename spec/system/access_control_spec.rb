# frozen_string_literal: true

require 'spec_helper'

describe 'access control', js: true do
  it 'prevents drivers from accessing supervisor resources' do
    when_current_user_is :driver
    incident = create :incident
    visit edit_supervisor_report_url(incident.supervisor_report)
    expect(page).not_to have_text 'Editing Supervisor Report'
    expect(page).to have_text 'You do not have permission to access this page.'
  end
  it 'prevents drivers from accessing staff resources' do
    when_current_user_is :driver
    visit incomplete_incidents_url
    expect(page).not_to have_text 'Incomplete Incidents'
    expect(page).to have_text 'You do not have permission to access this page.'
  end
  it 'prevents supervisors from accessing staff resources' do
    when_current_user_is :supervisor
    visit incomplete_incidents_url
    expect(page).not_to have_text 'Incomplete Incidents'
    expect(page).to have_text 'You do not have permission to access this page.'
  end
end
