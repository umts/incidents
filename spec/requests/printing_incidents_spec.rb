# frozen_string_literal: true

require 'spec_helper'

describe 'IncidentsController#show PDF' do
  let(:driver) { create :user, :driver }
  before(:each) { when_current_user_is driver }

  it 'is displayed in-browser' do
    report = create :incident_report, :with_incident, user: driver
    get incident_path(report.incident, format: :pdf)

    expect(response.headers['Content-Disposition'])
      .to match(/^inline/)
  end
  it 'has a filename if downloaded' do
    report = create :incident_report, :with_incident, user: driver
    get incident_path(report.incident, format: :pdf)

    expect(response.headers['Content-Disposition'])
      .to match(%Q{filename="#{report.incident.id}.pdf})
  end
  it 'prints a collision incident' do
    report = create :incident_report, :with_incident,
      :collision, user: driver
    get incident_path(report.incident, format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq 'application/pdf'
  end
  it 'prints a collision where the other driver is not the owner' do
    report = create :incident_report, :with_incident,
      :collision, :other_vehicle_not_driven_by_owner, user: driver
    get incident_path(report.incident, format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq 'application/pdf'
  end
  it 'prints a collision with police response' do
    report = create :incident_report, :with_incident,
      :collision, :police_on_scene, user: driver
    get incident_path(report.incident, format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq 'application/pdf'
  end
  it 'prints a passenger incident' do
    report = create :incident_report, :with_incident,
      :passenger_incident, user: driver
    get incident_path(report.incident, format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq 'application/pdf'
  end
  it 'prints a "not up to curb" passenger incident' do
    report = create :incident_report, :with_incident,
      :passenger_incident, :not_up_to_curb, user: driver
    get incident_path(report.incident, format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq 'application/pdf'
  end
  it 'prints an incomplete incident' do
    report = create :incident_report,
      :incomplete, user: driver
    build(:incident, driver_incident_report: report).save validate: false
    get incident_path(report.incident, format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq 'application/pdf'
  end
  it 'prints an incident with a supervisor report' do
    incident = create :incident # so that we also get supervisor reports
    incident.driver_incident_report.update user: driver
    get incident_path(incident, format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq 'application/pdf'
  end
  it 'prints an incident, no drug test, not FTA threshold' do
    sup_report = create :supervisor_report, test_status: 'Post Accident: No threshold met (no drug test)',
      reason_threshold_not_met: 'Because I said so.'
    incident = create :incident, supervisor_report: sup_report
    incident.driver_incident_report.update user: driver
    get incident_path(incident, format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq 'application/pdf'
  end
  it 'prints an incident, no drug test, discounted' do
    sup_report = create :supervisor_report, test_status: 'Post Accident: Threshold met and discounted (no drug test)',
      reason_driver_discounted: 'Because I said so.'
    incident = create :incident, supervisor_report: sup_report
    incident.driver_incident_report.update user: driver
    get incident_path(incident, format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq 'application/pdf'
  end
end
