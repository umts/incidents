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
      it 'allows filling in the number of pictures saved', js: true do
        expect(page).not_to have_text 'Number of pictures saved'
        check 'Were pictures taken?'
        expect(page).to have_text 'Number of pictures saved'
      end
      it 'does not require filling in the number of saved pictures', js: true do
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
      it 'allows filling in witness information', js: true do
        expect(page).not_to have_text 'Witness Information'
        check 'Were there witnesses?'
        expect(page).to have_text 'Witness Information'
      end
      it 'requires filling in the witness information', js: true do
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
      it 'allows filling in the reason for testing' do
        visit edit_supervisor_report_url(incident.supervisor_report)
        select 'Post Accident: Threshold met (completed drug test)', from: 'Test status'
        within('.test-info') do
          expect(page).to have_text 'bodily injury'
          expect(page).to have_text 'disabling damage'
          expect(page).to have_text 'fatality'
          expect(page).not_to have_text 'Completed alcohol test'
          expect(page).not_to have_text 'Observation made at'
          expect(page).not_to have_text 'Observation made at'
          %w[appearance behavior speech odor].each do |reason|
            expect(page).not_to have_text "Test due to employee #{reason}"
          end
        end
        select 'Reasonable Suspicion', from: 'Test status'
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
        select 'Post Accident: Threshold met and discounted', from: 'Test status'
        within('.test-info') do
          expect(page).not_to have_text 'bodily injury'
          expect(page).not_to have_text 'disabling damage'
          expect(page).not_to have_text 'fatality'
          expect(page).to have_text 'Please explain why the driver can be discounted.'
        end
        select 'No threshold met', from: 'Test status'
        within('.test-info') do
          expect(page).not_to have_text 'bodily injury'
          expect(page).not_to have_text 'disabling damage'
          expect(page).not_to have_text 'fatality'
          expect(page).to have_text 'Please explain how the FTA threshold is not met.'
        end
      end
    end
  end
end
