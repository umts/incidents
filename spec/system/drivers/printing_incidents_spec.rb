# frozen_string_literal: true

require 'spec_helper'

describe 'printing incidents' do
  let(:driver) { create :user, :driver }
  before(:each) { when_current_user_is driver }
  it 'shows a place to print incidents' do
    report = create :incident_report, :driver_report, :with_incident, user: driver
    visit incidents_url
    expect(page).to have_link 'Print'
    click_button 'Print'
    expect(page.current_url).to end_with incident_path(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :driver_report, :with_incident,
      :collision, user: driver
    visit incident_url(report.incident, format: :pdf)
    # No expectation needed, it either prints or it doesn't.
    # Not too much more we can do in Capybara.
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :driver_report, :with_incident,
      :collision, :other_vehicle_not_driven_by_owner, user: driver
    visit incident_url(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :driver_report, :with_incident,
      :collision, :police_on_scene, user: driver
    visit incident_url(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :driver_report, :with_incident,
      :passenger_incident, user: driver
    visit incident_url(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :driver_report, :with_incident,
      :passenger_incident, :not_up_to_curb, user: driver
    visit incident_url(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :driver_report, :with_incident,
      :passenger_incident, :injured_passenger, user: driver
    visit incident_url(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :driver_report, :with_incident,
      :incomplete, user: driver
    visit incident_url(report.incident, format: :pdf)
  end
end
