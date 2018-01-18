# frozen_string_literal: true

require 'spec_helper'

describe 'viewing incident XML as a staff member' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let!(:incident) { incident_in_divisions staff.divisions }
  it 'marks the incident as exported' do
    visit incidents_url
    expect(page).to have_selector 'table.incidents tbody tr', count: 1
    expect(page).to have_selector 'table.incidents th', text: 'Exported?'
    # Find the column which indicates whether the incident is exported.
    exported_column = page.find('table.incidents th', text: 'Exported?')
    # Find its number within the other columns.
    exported_column_index = page.find_all('table.incidents th').index exported_column
    # Find the corresponding column in the singular table row.
    exported_row_cell = page.find_all('table.incidents tbody td')[exported_column_index]
    # Expect it to have the "No" sign.
    within exported_row_cell do
      expect(page).to have_selector 'span.glyphicon-remove'
    end

    # This should mark it as exported.
    visit incident_url(incident, format: :xml)

    visit incidents_url
    # We assume that the number and positioning of the columns hasn't suddenly changed.
    exported_row_cell = page.find_all('table.incidents tbody td')[exported_column_index]
    # Expect it to have the "Yes" sign.
    within exported_row_cell do
      expect(page).to have_selector 'span.glyphicon-ok'
    end
  end
  context 'with motor vehicle collisions' do
    let(:driver_report) { create :incident_report, :driver_report, :collision }
    let(:incident) { create :incident, driver_incident_report: driver_report }
    it 'works' do
      expect { visit incident_url(incident, format: :xml) }.not_to raise_error
    end
  end
end

describe 'viewing incident XML as a driver' do
  let(:incident) { create :incident }
  it "you can't" do
    when_current_user_is :driver
    visit incident_url(incident, format: :xml)
    expect(page).to have_text 'You do not have permission to access this page.'
  end
end
