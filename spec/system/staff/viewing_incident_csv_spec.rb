# frozen_string_literal: true

require 'spec_helper'

describe 'viewing incident CSV as a staff member' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let(:driver_report) { create :incident_report, :driver_report, :collision }
  let(:incident) { create :incident, driver_incident_report: driver_report }
  it 'works' do
    expect { visit incident_url(incident, format: :csv) }.not_to raise_error
  end
end

describe 'batch exporting CSV' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let!(:incident) { incident_in_divisions staff.divisions }
  it 'marks incidents as exported', js: true do
    visit incidents_url
    expect(page).to have_selector 'table.incidents tbody tr', count: 1
    expect(page).to have_selector 'table.incidents th', text: 'Hastus?'
    exported_column = page.find('table.incidents th', text: 'Hastus?')
    exported_column_index = page.find_all('table.incidents th').index exported_column
    exported_row_cell = page.find_all('table.incidents tbody td')[exported_column_index]
    within exported_row_cell do
      expect(page).to have_selector 'span.glyphicon-remove'
    end

    click_button 'Batch export'
    check 'batch_export'
    click_button 'Generate CSV export (1 selected)'

    visit incidents_url
    exported_row_cell = page.find_all('table.incidents tbody td')[exported_column_index]
    within exported_row_cell do
      expect(page).to have_selector 'span.glyphicon-ok'
    end
  end
end

