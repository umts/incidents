# frozen_string_literal: true

require 'spec_helper'

describe 'special incident fields' do
  let(:driver) { create :user, :driver }
  before(:each) { when_current_user_is driver }
  describe 'collision related fields', js: true do
    context 'without collision' do
      before :each do
        visit new_incident_path
      end
      it 'allows filling in collision fields' do
        expect(page).not_to have_text 'Motor Vehicle Collision Information'
        check 'Did the incident involve a collision?'
        expect(page).to have_text 'Motor Vehicle Collision Information'
      end
      it 'does not require filling in fields for collisions' do
        fill_in_base_incident_fields
        check 'Did the incident involve a collision?'
        click_on 'Save report and preview PDF'
        page.driver.browser.switch_to.alert.accept

        expect(page).not_to have_text('cannot be marked as completed')
      end
    end
    context 'with collision' do
      it 'shows collision fields for collision incidents' do
        driver_report = create :incident_report,
                               :driver_report,
                               :with_incident,
                               :collision,
                               user: driver
        create :incident, driver_incident_report: driver_report
        expect(driver_report).to be_motor_vehicle_collision
        visit edit_incident_report_url(driver_report)
        expect(page).to have_text 'Motor Vehicle Collision Information'
      end
    end
  end

  describe 'other vehicle related fields', js: true do
    context 'without other vehicle info' do
      it 'allows filling in other vehicle info as necessary' do
        visit new_incident_path
        check 'Did the incident involve a collision?'
        expect(page).to have_field 'Other vehicle owner name'
        check 'Is the other driver involved the owner of the vehicle?'
        expect(page).not_to have_field 'Other vehicle owner name'
      end
    end
    context 'with other vehicle info' do
      it 'shows other vehicle owner information as necessary' do
        driver_report = create :incident_report,
                               :driver_report,
                               :with_incident,
                               :collision,
                               :other_vehicle_not_driven_by_owner,
                               user: driver
        create :incident, driver_incident_report: driver_report
        expect(driver_report).not_to be_other_vehicle_owned_by_other_driver
        visit edit_incident_report_url(driver_report)
        expect(page).to have_field 'Other vehicle owner name'
      end
    end
  end

  describe 'police related fields', js: true do
    context 'without police info' do
      before :each do
        visit new_incident_path
      end
      it 'allows filling in police info' do
        check 'Did the incident involve a collision?'
        expect(page).not_to have_field 'Police badge number'
        check 'Did police respond to the incident?'
        expect(page).to have_field 'Police badge number'
      end
      it 'does not require police info' do
        fill_in_base_incident_fields
        check 'Did the incident involve a collision?'
        check 'Did police respond to the incident?'
        click_on 'Save report and preview PDF'
        page.driver.browser.switch_to.alert.accept

        expect(page).not_to have_text('cannot be marked as completed')
      end
    end
    context 'with police info' do
      it 'shows police fields as necessary' do
        driver_report = create :incident_report,
                               :driver_report,
                               :with_incident,
                               :collision,
                               :police_on_scene,
                               user: driver
        create :incident, driver_incident_report: driver_report
        expect(driver_report).to be_police_on_scene
        visit edit_incident_report_url(driver_report)
        expect(page).to have_field 'Police badge number'
      end
    end
  end

  describe 'passenger incident related fields', js: true do
    context 'without passenger incidents' do
      before :each do
        visit new_incident_path
      end
      it 'allows filling in passenger incident fields' do
        expect(page).not_to have_text 'Passenger Incident Information'
        check 'Did the incident involve a passenger?'
        expect(page).to have_text 'Passenger Incident Information'
      end
      it 'does not require filling in passenger incident fields' do
        fill_in_base_incident_fields
        check 'Did the incident involve a passenger?'
        expect(page).to have_text 'Passenger Incident Information'
        click_on 'Save report and preview PDF'
        page.driver.browser.switch_to.alert.accept

        expect(page).not_to have_text('cannot be marked as completed')
      end
    end
    context 'with passenger incidents' do
      it 'shows passenger fields for passenger incidents' do
        driver_report = create :incident_report,
                               :driver_report,
                               :with_incident,
                               :passenger_incident,
                               user: driver
        expect(driver_report).to be_passenger_incident
        visit edit_incident_report_url(driver_report)
        expect(page).to have_text 'Passenger Incident Information'
      end
    end
  end

  describe 'reason not up to curb related fields', js: true do
    before :each do
      visit new_incident_path
    end
    context 'without reason not up to curb' do
      it 'allows filling in reason bus was not up to curb' do
        check 'Did the incident involve a passenger?'
        expect(page).not_to have_field 'Reason not up to curb'
        select 'Stopped', from: 'Motion of bus'
        uncheck 'Was the bus pulled completely up to the curb?'
        expect(page).to have_field 'Reason not up to curb'
      end
      it 'does not require filling in reason not up to curb' do
        fill_in_base_incident_fields
        check 'Did the incident involve a passenger?'
        select 'Stopped', from: 'Motion of bus'
        uncheck 'Was the bus pulled completely up to the curb?'
        click_on 'Save report and preview PDF'
        page.driver.browser.switch_to.alert.accept

        expect(page).not_to have_text('cannot be marked as completed')
      end
    end
    context 'with reason not up to curb' do
      it 'shows reason not up to curb field as necessary' do
        driver_report = create :incident_report,
                               :driver_report,
                               :with_incident,
                               :passenger_incident,
                               :not_up_to_curb,
                               user: driver
        expect(driver_report).to be_needs_reason_not_up_to_curb
        visit edit_incident_report_url(driver_report)
        expect(page).to have_field 'Reason not up to curb'
      end
    end
  end
end
