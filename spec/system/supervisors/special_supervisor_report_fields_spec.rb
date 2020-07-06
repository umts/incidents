# frozen_string_literal: true

require 'spec_helper'

describe 'special supervisor report fields' do
  let(:supervisor) { create :user, :supervisor }
  before(:each) do
    when_current_user_is supervisor
    visit edit_supervisor_report_url(supervisor_report)
  end
  let(:supervisor_incident_report) { create :incident_report, user: supervisor }
  let(:supervisor_report) { create :supervisor_report }
  let!(:incident) do
    create :incident,
           supervisor_incident_report: supervisor_incident_report,
           supervisor_report: supervisor_report
  end
  describe 'pictures saved related fields' do
    context 'without pictures saved' do
      it 'allows filling in the number of pictures saved' do
        expect(page).not_to have_text 'Number of pictures saved'
        check 'Were pictures taken?'
        expect(page).to have_text 'Number of pictures saved'
      end
      it 'does not require filling in the number of saved pictures' do
        check 'Were pictures taken?'
        fill_in 'Number of pictures saved', with: ''
        click_button 'Save supervisor report'
        expect(page).to have_selector 'p.notice',
                                      text: 'Incident report was successfully saved.'
      end
    end
    context 'with pictures saved' do
      let(:supervisor_report) { create :supervisor_report, :with_pictures }

      it 'shows the number of saved pictures for reports where it applies' do
        expect(page).to have_text 'Number of pictures saved'
      end
    end
  end

  describe 'witness information related fields' do
    context 'without witnesses' do
      it 'allows filling in witness information' do
        expect(page).not_to have_text 'Witness Information'
        check 'Were there witnesses?'
        expect(page).to have_text 'Witness Information'
      end
      it 'requires filling in the witness information' do
        check 'Were there witnesses?'
        click_button 'Save supervisor report'
        expect(page).to have_text "Witnesses name can't be blank"
      end
    end
    context 'with witnesses' do
      let(:supervisor_report) { create :supervisor_report, :with_witness }
      it 'shows witness information for reports where it applies' do
        expect(page).to have_text 'Witness Information'
        fill_in 'Name', with: 'Cornelius Fudge'
        click_button 'Save supervisor report'
        expect(page).to have_selector 'p.notice',
                                      text: 'Incident report was successfully saved.'
        expect(page).to have_text 'Cornelius Fudge'
      end
    end
  end

  describe 'test completion related fields' do
    context 'with test conducted' do
      let(:supervisor_report) { create :supervisor_report, :tested_post_accident }

      it 'allows filling in fields related to a test not being completed' do
        expect(page)
          .not_to have_text 'Please document why a test was not conducted.'
        uncheck 'Completed drug or alcohol test?'
        expect(page)
          .to have_text 'Please document why a test was not conducted.'
      end

      it 'allows filling in the reason for testing' do
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
      it 'requires selecting a reason why a test was not conducted' do
        uncheck :supervisor_report_fta_threshold_not_met
        click_button 'Save supervisor report'
        expect(page)
          .to have_text 'You must provide a reason why no test was conducted.'
      end
    end
  end

  describe 'FTA threshold related fields' do
    context 'with FTA threshold met' do
      let(:supervisor_report) { create :supervisor_report, :with_da_test }
      it 'prohibits filling in a reason why the FTA threshold was not met' do
        expect(page)
          .not_to have_text 'Please explain how the FTA threshold is not met.'
      end
    end
    context 'without FTA threshold met' do
      it 'shows FTA threshold information when it applies' do
        expect(page).to have_text 'Please explain how the FTA threshold is not met.'
      end
      it 'requires explaining how the FTA threshold was not met' do
        fill_in 'Please explain how the FTA threshold is not met.', with: ''
        click_button 'Save supervisor report'
        expect(page)
          .to have_text 'This supervisor report has 1 missing value and so cannot be marked as completed.'
      end
    end
  end

  describe 'driver discount related fields' do
    context 'without driver discounted' do
      it 'allows filling in a reason why a driver can be discounted' do
        expect(page).not_to have_text 'Please explain why the driver can be discounted.'
        check 'I can completely discount the operator, a safety-sensitive employee, as a contributing factor to the incident.'
        expect(page).to have_text 'Please explain why the driver can be discounted.'
      end
      it 'requires explaining why the driver can be discounted' do
        check 'I can completely discount the operator, a safety-sensitive employee, as a contributing factor to the incident.'
        click_button 'Save supervisor report'
        expect(page)
          .to have_text 'This supervisor report has 1 missing value and so cannot be marked as completed.'
      end
    end

    context 'with driver discounted' do
    let :supervisor_report do
      create :supervisor_report,
             driver_discounted: true,
             fta_threshold_not_met: false,
             reason_threshold_not_met: nil,
             reason_driver_discounted: 'Placeholder'
    end
      it 'shows driver discount information when it applies' do
        expect(page)
          .to have_text 'Please explain why the driver can be discounted.'
      end
    end
  end
end
