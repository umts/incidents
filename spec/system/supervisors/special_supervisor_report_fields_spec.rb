# frozen_string_literal: true

require 'spec_helper'

describe 'special supervisor report fields' do
  let(:supervisor) { create :user, :supervisor }
  before(:each) { when_current_user_is supervisor }
  let(:supervisor_incident_report) { create :incident_report, user: supervisor }
  let(:incident) do
    create :incident, supervisor_incident_report: supervisor_incident_report
  end
  describe 'pictures saved related fields' do
    context 'without pictures saved' do
      before :each do
        incident.supervisor_report.update! pictures_saved: false
        visit edit_supervisor_report_url(incident.supervisor_report)
      end
      it 'allows filling in the number of pictures saved', js: true do
        expect(page).not_to have_text 'Number of pictures saved'
        check 'Were pictures taken?'
        expect(page).to have_text 'Number of pictures saved'
      end
      it 'does not require filling in the number of saved pictures', js: true do
        check 'Were pictures taken?'
        fill_in 'Number of pictures saved', with: ''
        click_button 'Save supervisor report'
        wait_for_ajax!
        expect(page).to have_selector 'p.notice',
                                      text: 'Incident report was successfully saved.'
      end
    end
    context 'with pictures saved' do
      it 'shows the number of saved pictures for reports where it applies', js: true do
        incident.supervisor_report.update! pictures_saved: true
        visit edit_supervisor_report_url(incident.supervisor_report)
        expect(page).to have_text 'Number of pictures saved'
      end
    end
  end

  describe 'witness information related fields' do
    before :each do
      incident.supervisor_report.witnesses = []
    end
    context 'without witnesses' do
      before :each do
        visit edit_supervisor_report_url(incident.supervisor_report)
      end
      it 'allows filling in witness information', js: true do
        expect(page).not_to have_text 'Witness Information'
        check 'Were there witnesses?'
        expect(page).to have_text 'Witness Information'
      end
      it 'requires filling in the witness information', js: true do
        check 'Were there witnesses?'
        click_button 'Save supervisor report'
        wait_for_ajax!
        expect(page).to have_text "Witnesses name can't be blank"
      end
    end
    context 'with witnesses' do
      it 'shows witness information for reports where it applies', js: true do
        create :witness, supervisor_report: incident.supervisor_report
        visit edit_supervisor_report_url(incident.supervisor_report)
        expect(page).to have_text 'Witness Information'
        fill_in 'Name', with: 'Cornelius Fudge'
        click_button 'Save supervisor report'
        wait_for_ajax!
        expect(page).to have_selector 'p.notice',
                                      text: 'Incident report was successfully saved.'
        expect(page).to have_text 'Cornelius Fudge'
      end
    end
  end

  describe 'test completion related fields' do
    context 'with test conducted' do
      it 'allows filling in fields related to a test not being completed', js: true do
        incident.supervisor_report.update! completed_drug_or_alcohol_test: true
        visit edit_supervisor_report_url(incident.supervisor_report)
        expect(page)
          .not_to have_text 'Please document why a test was not conducted.'
        uncheck 'Completed drug or alcohol test?'
        expect(page)
          .to have_text 'Please document why a test was not conducted.'
      end

      it 'allows filling in the reason for testing', js: true do
        incident.supervisor_report.update! completed_drug_or_alcohol_test: true,
                                           reason_test_completed: 'Post-Accident'
        visit edit_supervisor_report_url(incident.supervisor_report)
        within('.test-info') do
          expect(page).to have_text 'bodily injury'
          expect(page).to have_text 'disabling damage'
          expect(page).to have_text 'fatality'
          expect(page).not_to have_text 'Completed drug test'
          expect(page).not_to have_text 'Completed alcohol test'
          expect(page).not_to have_text 'Observation made at'
          expect(page).not_to have_text 'Observation made at'
          %w[appearance behavior speech odor].each do |reason|
            expect(page).not_to have_text "Test due to employee #{reason}"
          end
        end
        select 'Reasonable Suspicion', from: 'Reason test completed'
        within('.test-info') do
          expect(page).not_to have_text 'bodily injury'
          expect(page).not_to have_text 'disabling damage'
          expect(page).not_to have_text 'fatality'
          expect(page).to have_text 'Completed drug test'
          expect(page).to have_text 'Completed alcohol test'
          expect(page).to have_text 'Observation made at'
          expect(page).to have_text 'Observation made at'
          %w[appearance behavior speech odor].each do |reason|
            expect(page).to have_text "Test due to employee #{reason}"
          end
        end
      end
    end

    context 'without test conducted' do
      it 'requires selecting a reason why a test was not conducted', js: true do
        incident.supervisor_report.update! completed_drug_or_alcohol_test: true,
                                           fta_threshold_not_met: true,
                                           driver_discounted: true,
                                           reason_driver_discounted: 'Placeholder',
                                           reason_threshold_not_met: 'Placeholder'
        visit edit_supervisor_report_url(incident.supervisor_report)
        uncheck 'Completed drug or alcohol test?'
        uncheck :supervisor_report_fta_threshold_not_met
        uncheck :supervisor_report_driver_discounted
        click_button 'Save supervisor report'
        wait_for_ajax!
        expect(page)
          .to have_text 'You must provide a reason why no test was conducted.'
      end
    end
  end

  describe 'FTA threshold related fields' do
    context 'with FTA threshold met' do
      before :each do
        incident.supervisor_report.update! completed_drug_or_alcohol_test: false,
                                           fta_threshold_not_met: false,
                                           driver_discounted: true,
                                           reason_driver_discounted: 'Placeholder'
        visit edit_supervisor_report_url(incident.supervisor_report)
      end
      it 'allows filling in a reason why the FTA threshold was not met', js: true do
        expect(page)
          .not_to have_text 'Please explain how the FTA threshold is not met.'
        check 'Accident does not meet FTA post-accident testing criteria. Therefore, no drug or alcohol testing is permitted under FTA.'
        expect(page).to have_text 'Please explain how the FTA threshold is not met.'
        check 'Accident does not meet FTA post-accident testing criteria. Therefore, no drug or alcohol testing is permitted under FTA.'
      end
      it 'requires explaining how the FTA threshold was not met', js: true do
        check 'Accident does not meet FTA post-accident testing criteria. Therefore, no drug or alcohol testing is permitted under FTA.'
        click_button 'Save supervisor report'
        wait_for_ajax!
        expect(page)
          .to have_text 'This supervisor report has 1 missing value and so cannot be marked as completed.'
      end
    end
    context 'without FTA threshold met' do
      it 'shows FTA threshold information when it applies', js: true do
        incident.supervisor_report.update! completed_drug_or_alcohol_test: false,
                                           fta_threshold_not_met: true,
                                           driver_discounted: false,
                                           reason_threshold_not_met: 'Placeholder'
        visit edit_supervisor_report_url(incident.supervisor_report)
        expect(page).to have_text 'Please explain how the FTA threshold is not met.'
      end
    end
  end

  describe 'driver discount related fields' do
    context 'without driver discounted' do
      before :each do
        incident.supervisor_report.update! completed_drug_or_alcohol_test: false,
                                           driver_discounted: false,
                                           fta_threshold_not_met: true,
                                           reason_threshold_not_met: 'Placeholder'
      end
      it 'allows filling in a reason why a driver can be discounted', js: true do
        visit edit_supervisor_report_url(incident.supervisor_report)
        expect(page).not_to have_text 'Please explain why the driver can be discounted.'
        check 'I can completely discount the operator, a safety-sensitive employee, as a contributing factor to the incident.'
        expect(page).to have_text 'Please explain why the driver can be discounted.'
      end
      it 'requires explaining why the driver can be discounted', js: true do
        incident.supervisor_report.update! reason_driver_discounted: nil
        visit edit_supervisor_report_url(incident.supervisor_report)
        check 'I can completely discount the operator, a safety-sensitive employee, as a contributing factor to the incident.'
        expect(page)
          .to have_text 'Please explain why the driver can be discounted.'
        click_button 'Save supervisor report'
        wait_for_ajax!
        expect(page)
          .to have_text 'This supervisor report has 1 missing value and so cannot be marked as completed.'
      end
    end
    context 'with driver discounted' do
      it 'shows driver discount information when it applies', js: true do
        incident.supervisor_report.update! completed_drug_or_alcohol_test: false,
                                           driver_discounted: true,
                                           fta_threshold_not_met: false,
                                           reason_driver_discounted: 'Placeholder'
        visit edit_supervisor_report_url(incident.supervisor_report)
        expect(page)
          .to have_text 'Please explain why the driver can be discounted.'
      end
    end
  end
end
