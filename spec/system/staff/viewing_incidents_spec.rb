# frozen_string_literal: true

require 'spec_helper'

describe 'viewing incidents as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  context 'searching by claim number' do
    it 'allows searching for incidents by claim number' do
      incident_in_divisions(staff.divisions, claim_number: 'apples')
      incident_in_divisions(staff.divisions, claim_number: 'bananas')
      visit incidents_path
      expect(page).to have_selector 'table.incidents tbody tr', count: 2
      fill_in 'Search by claim number', with: 'bananas'
      click_button 'Search'
      # just the bananas
      expect(page).to have_selector 'table.incidents tbody tr', count: 1
    end
  end

  context 'with an injured passenger transported to hospital' do
    it 'displays this' do
      pax = create :injured_passenger, transported_to_hospital: true
      report = pax.incident_report
      report.update passenger_incident: true
      incident = create :incident, driver_incident_report: report
      visit incident_path(incident)
      expect(page).to have_text 'Transported to hospital'
    end
  end
  context 'with an injured passenger not transported to hospital' do
    it 'displays this' do
      pax = create :injured_passenger, transported_to_hospital: false
      report = pax.incident_report
      report.update passenger_incident: true
      incident = create :incident, driver_incident_report: report
      visit incident_path(incident)
      expect(page).to have_text 'Not transported to hospital'
    end
  end

  context 'with incomplete incidents' do
    let!(:incident) { incident_in_divisions staff.divisions, completed: false }
    it 'allows viewing incomplete incidents', js: true do
      visit incidents_path
      click_button 'Incomplete Incidents 1'
      expect(page).to have_current_path incomplete_incidents_path
    end
  end
  context 'with no incomplete incidents' do
    it 'tells you there are not any' do
      visit incomplete_incidents_path
      expect(page).to have_selector 'p.notice',
                                    text: 'No incomplete incidents.'
      expect(page).to have_current_path incidents_path
    end
  end

  context 'with unclaimed incidents' do
    let!(:incident) { incident_in_divisions staff.divisions, :unclaimed }
    it 'allows viewing unclaimed incidents', js: true do
      visit incidents_path
      click_button 'Unclaimed Incidents 1'
      expect(page).to have_current_path unclaimed_incidents_path
    end
  end
  context 'with no unclaimed incidents' do
    it 'tells you there are not any' do
      visit unclaimed_incidents_path
      expect(page).to have_selector 'p.notice',
                                    text: 'No unclaimed incidents.'
      expect(page).to have_current_path incidents_path
    end
  end

  context 'navigating by date', js: true do
    before(:each) { Timecop.freeze Date.new(2018, 1, 4) }
    after(:each) { Timecop.return }
    it 'starts out navigating by month' do
      visit incidents_path
      expect(page).to have_selector 'h2',
                                    text: 'Monday, January 1, 2018 — Wednesday, January 31, 2018'
    end
    it 'allows going to the previous month' do
      visit incidents_path
      click_button '← Previous month'
      expect(page).to have_selector 'h2',
                                    text: 'Friday, December 1, 2017 — Sunday, December 31, 2017'
    end
    it 'allows going to the next month' do
      visit incidents_path
      click_button 'Next month →'
      expect(page).to have_selector 'h2',
                                    text: 'Thursday, February 1, 2018 — Wednesday, February 28, 2018'
    end
    it 'allows navigating by week' do
      visit incidents_path
      click_button 'View single week'
      expect(page).to have_selector 'h2',
                                    text: 'Sunday, December 31, 2017 — Saturday, January 6, 2018'
    end
    context 'navigating by week' do
      it 'goes to the first week in the month, not the current week' do
        Timecop.freeze Date.new(2018, 1, 7) do
          visit incidents_path
          click_button 'View single week'
          expect(page).not_to have_selector 'h2',
                                            text: 'Sunday, January 7, 2018 — Saturday, January 13, 2018'
          expect(page).to have_selector 'h2',
                                        text: 'Sunday, December 31, 2017 — Saturday, January 6, 2018'
        end
      end
    end
    it 'allows going from week mode back to month mode' do
      visit incidents_path(mode: 'week')
      expect(page).to have_selector 'h2',
                                    text: 'Sunday, December 31, 2017 — Saturday, January 6, 2018'
      click_button 'View for whole month'
      # Note that it doesn't go back to January,
      # because the first day of the week is in December.
      expect(page).to have_selector 'h2',
                                    text: 'Friday, December 1, 2017 — Sunday, December 31, 2017'
    end
    it 'allows going to the next week' do
      visit incidents_path(mode: 'week')
      click_button 'Next week →'
      expect(page).to have_selector 'h2',
                                    text: 'Sunday, January 7, 2018 — Saturday, January 13, 2018'
    end
    it 'allows going to the previous week' do
      visit incidents_path(mode: 'week')
      click_button '← Previous week'
      expect(page).to have_selector 'h2',
                                    text: 'Sunday, December 24, 2017 — Saturday, December 30, 2017'
    end
  end

  context 'with a passenger incident' do
    it 'displays where the incident occurred' do
      driver = create :user, :driver, divisions: staff.divisions
      report = create :incident_report,
                      user: driver,
                      passenger_incident: true,
                      occurred_front_door: true,
                      occurred_while_exiting: true
      incident = create :incident, driver_incident_report: report
      visit incident_path(incident)
      expect(page).to have_text 'Front door, While exiting'
    end
  end

  context 'with multiple passenger incidents' do
    it 'displays all the passengers' do
      report = create :incident_report
      pax = create :injured_passenger, name: 'Emma', incident_report: report
      pax2 = create :injured_passenger, name: 'Tyler', incident_report: report
      report.update passenger_incident: true
      incident = create :incident, driver_incident_report: report
      visit incident_path(incident)
      expect(page).to have_text pax.name
      expect(page).to have_text pax2.name
    end
  end
end
