# frozen_string_literal: true

require 'spec_helper'

describe 'viewing incident XML as a staff member' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let!(:incident) { incident_in_divisions staff.divisions }
  it 'marks the incident as exported' do
    visit incidents_url
    expect(page).to have_selector 'table.incidents tbody tr', count: 1
    expect(page).to have_selector 'table.incidents th', text: 'Hastus?'
    # Find the column which indicates whether the incident is exported.
    exported_column = page.find('table.incidents th', text: 'Hastus?')
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

describe 'batch exporting XML' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  let!(:incident) { incident_in_divisions staff.divisions }
  it 'marks incidents as exported' do
    visit incidents_url
    expect(page).to have_selector 'table.incidents tbody tr', count: 1
    expect(page).to have_selector 'table.incidents th', text: 'Hastus?'
    # Find the column which indicates whether the incident is exported.
    exported_column = page.find('table.incidents th', text: 'Hastus?')
    # Find its number within the other columns.
    exported_column_index = page.find_all('table.incidents th').index exported_column
    # Find the corresponding column in the singular table row.
    exported_row_cell = page.find_all('table.incidents tbody td')[exported_column_index]
    # Expect it to have the "No" sign.
    within exported_row_cell do
      expect(page).to have_selector 'span.glyphicon-remove'
    end

    # This should mark it as exported.
    click_button 'Batch export'
    check 'batch_export'
    click_button 'Generate XML export (1 selected)'

    visit incidents_url
    # We assume that the number and positioning of the columns hasn't suddenly changed.
    exported_row_cell = page.find_all('table.incidents tbody td')[exported_column_index]
    # Expect it to have the "Yes" sign.
    within exported_row_cell do
      expect(page).to have_selector 'span.glyphicon-ok'
    end
  end

  it 'allows selecting all shown incidents' do
    # 3 plus the one we created above should be 4.
    3.times { incident_in_divisions staff.divisions }
    visit incidents_url
    click_button 'Batch export'

    expect(page).to have_unchecked_field 'batch_export', count: 4
    click_button 'Select all (4)'
    expect(page).to have_checked_field 'batch_export', count: 4
  end
end

describe 'batch exporting incident XML or CSV as a staff member' do
  context 'with staff in multiple divisions, filtering by a single division' do
    let(:division1) { create :division }
    let(:division2) { create :division }
    let(:staff) { create :user, :staff, divisions: [division1, division2] }
    before(:each) { when_current_user_is staff }
    it 'allows selecting all incidents in the filtered division' do
      3.times { incident_in_divisions [division1] }
      3.times { incident_in_divisions [division2] }

      visit incidents_url
      expect(page).to have_selector 'table.incidents tbody tr', count: 6
      click_button division1.name
      expect(page).to have_selector 'table.incidents tbody tr', count: 3

      click_button 'Batch export'
      click_button 'Select all (3)'

      expect(page).to have_checked_field 'batch_export', count: 3
      # even if we un-filter
      click_button 'All'
      expect(page).to have_checked_field 'batch_export', count: 3
    end
  end
end
