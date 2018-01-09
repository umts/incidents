# frozen_string_literal: true

require 'spec_helper'

describe 'printing incidents' do
  let(:driver) { create :user, :driver }
  before(:each) { when_current_user_is driver }
  it 'shows a place to print incidents' do
    report = create :incident_report, :with_incident, user: driver
    visit incidents_url
    expect(page).to have_link 'Print'
    click_button 'Print'
    expect(page.current_url).to end_with incident_path(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :with_incident,
      :collision, user: driver
    visit incident_url(report.incident, format: :pdf)
    # No expectation needed, it either prints or it doesn't.
    # Not too much more we can do in Capybara.
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :with_incident,
      :collision, :other_vehicle_not_driven_by_owner, user: driver
    visit incident_url(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :with_incident,
      :collision, :police_on_scene, user: driver
    visit incident_url(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :with_incident,
      :passenger_incident, user: driver
    visit incident_url(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report, :with_incident,
      :passenger_incident, :not_up_to_curb, user: driver
    visit incident_url(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    report = create :incident_report,
      :incomplete, user: driver
    build(:incident, driver_incident_report: report).save validate: false
    visit incident_url(report.incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    incident = create :incident # so that we also get supervisor reports
    incident.driver_incident_report.update user: driver
    visit incident_url(incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    sup_report = create :supervisor_report, completed_drug_or_alcohol_test: false,
      fta_threshold_not_met: true,
      reason_threshold_not_met: 'Because I said so.'
    incident = create :incident, supervisor_report: sup_report
    incident.driver_incident_report.update user: driver
    visit incident_url(incident, format: :pdf)
  end
  it 'prints different kinds of incidents' do
    sup_report = create :supervisor_report, completed_drug_or_alcohol_test: false,
      driver_discounted: true,
      reason_driver_discounted: 'Because I said so.'
    incident = create :incident, supervisor_report: sup_report
    incident.driver_incident_report.update user: driver
    visit incident_url(incident, format: :pdf)
  end
end
