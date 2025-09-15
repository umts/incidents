# frozen_string_literal: true

require 'spec_helper'

describe 'access control' do
  it 'prevents drivers from accessing supervisor resources' do
    when_current_user_is :driver
    incident = create :incident
    visit edit_supervisor_report_path(incident.supervisor_report)
    expect(page).to have_http_status :unauthorized
  end

  it 'prevents drivers from accessing staff resources' do
    when_current_user_is :driver
    visit incomplete_incidents_path
    expect(page).to have_http_status :unauthorized
  end

  it 'prevents supervisors from accessing staff resources' do
    when_current_user_is :supervisor
    visit incomplete_incidents_path
    expect(page).to have_http_status :unauthorized
  end
end
