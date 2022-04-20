# frozen_string_literal: true

require 'spec_helper'

describe 'editing supervisor reports as a supervisor' do
  let(:incident) { create :incident }
  let(:supervisor) { incident.supervisor }

  before { when_current_user_is supervisor }

  it 'allows editing supervisor reports', js: true do
    visit edit_incident_path(incident)
    click_on 'Edit Supervisor Report'
    expect(page).to have_current_path edit_supervisor_report_path(incident.supervisor_report)
    check 'Were pictures taken?'
    fill_in 'Number of pictures saved', with: 37
    click_button 'Save supervisor report'
    expect(page).to have_selector 'p.notice',
                                  text: 'Incident report was successfully saved.'
    expect(page).to have_text 'Number of pictures saved: 37'
  end

  it 'reloads the edit page if the report is invalid' do
    incident.remove_supervisor
    incident.claim_for(supervisor)

    visit edit_incident_path(incident)
    click_on 'Edit Supervisor Report'
    select 'Post Accident: Threshold met and discounted' # But don't give a reason

    click_button 'Save supervisor report'

    expect(page).to have_current_path supervisor_report_path(incident.supervisor_report)
    expect(page).to have_text 'cannot be marked as complete'
  end

  context 'when admin deletes the incident' do
    it 'displays a nice error message' do
      visit edit_incident_path(incident)
      click_on 'Edit Supervisor Report'
      expect(page).to have_content 'Editing Supervisor Report'
      incident.destroy
      click_button 'Save supervisor report'
      expect(page).to have_selector 'p.notice',
                                    text: 'This incident report no longer exists.'
    end
  end

  context 'when adding multiple witnesses' do
    it 'displays all of them', js: true do
      # there is one witness filled in otherwise
      incident.supervisor_report.witnesses = []
      visit edit_incident_path(incident)
      click_on 'Edit Supervisor Report'
      expect(page).to have_content 'Editing Supervisor Report'
      check 'Were there witnesses?'
      expect(page).to have_text 'Witness Information'
      fill_in 'Name', with: 'Adam'
      fill_in 'Address', with: '255 Governors Dr, Amherst'
      click_button 'Add witness info'
      expect(page).to have_text 'Witness Information'
      fill_in 'supervisor_report_witnesses_attributes_1_name',
              with: 'Karin'
      fill_in 'supervisor_report_witnesses_attributes_1_address',
              with: '51 Forestry Way, Amherst'
      click_button 'Save supervisor report'

      visit incident_path(incident)
      expect(page).to have_selector 'h2', text: 'Supervisor Incident Report'
      expect(page).to have_text 'Witness Information'
      expect(page).to have_selector 'li',
                                    text: 'Adam; 255 Governors Dr, Amherst'
      expect(page).to have_selector 'li',
                                    text: 'Karin; 51 Forestry Way, Amherst'
    end
  end

  context 'when deleting a witness' do
    it 'displays the current witnesses', js: true do
      incident.supervisor_report.witnesses = []
      witness = create :witness, supervisor_report: incident.supervisor_report
      witness2 = create :witness, supervisor_report: incident.supervisor_report
      visit edit_incident_path(incident)
      click_on 'Edit Supervisor Report'
      expect(page).to have_content 'Editing Supervisor Report'
      click_button 'Delete witness info'
      click_button 'Save supervisor report'

      visit incident_path(incident)
      expect(page).not_to have_content witness2.name
      expect(page).to have_content witness.name
      expect(page).to have_selector 'h2', text: 'Supervisor Report'
      expect(page).to have_text 'Witness Information'
      expect(page).to have_selector 'li', count: 1
    end
  end

  context 'when submitting with a test status' do
    let(:supervisor_report) { incident.supervisor_report }
    let(:comment) { 'A nice comment.' }

    before do
      visit edit_supervisor_report_path(supervisor_report)
      select 'Post Accident: Threshold met and discounted', from: 'Test status'
    end

    it 'saves the correct amplifying comment', js: true do
      fill_in 'Please explain why the driver can be discounted.', with: 'Some dumb comment.'
      select 'Post Accident: Threshold met (completed drug test)', from: 'Test status'
      # Capybara can't find the new label even when it's visible
      fill_in id: 'threshold-met-comments', with: comment
      click_button 'Save supervisor report'
      expect(page).to have_css('p', text: comment)
    end

    context 'without amplifying comments' do
      before do
        fill_in 'Please explain why the driver can be discounted.', with: ''
        click_button 'Save supervisor report'
      end

      it 'does not let you leave amplifying comments blank' do
        expect(page).to have_css('#error_explanation', text: "Amplifying comments can't be blank")
      end

      it 'shows the correct amplifying comments field to fill' do
        expect(page).to have_css('textarea#reason-driver-discounted-comments')
      end
    end
  end
end
