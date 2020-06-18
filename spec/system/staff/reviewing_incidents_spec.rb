# frozen_string_literal: true

require 'spec_helper'

describe 'reviewing incidents as staff', js: true do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }

  context 'with an uncompleted incident' do
    let!(:incident) { incident_in_divisions staff.divisions, completed: false }
    it 'is not possible to review' do
      visit incidents_url
      expect(page).to have_selector 'table.incidents tbody tr', count: 1
      click_button 'View'
      expect(page.current_url).to end_with incident_path(incident)
      expect(page).not_to have_selector 'h3', text: 'Staff Review'
    end
  end
  context 'with a completed incident' do
    let!(:incident) { incident_in_divisions staff.divisions, :completed }
    it 'is possible to review' do
      visit incidents_url
      expect(page).to have_selector 'table.incidents tbody tr', count: 1
      click_button 'View'
      expect(page.current_url).to end_with incident_path(incident)
      fill_in 'Add your review', with: 'This is my review.'
      click_button 'Create staff review'
      expect(page).to have_selector 'p.notice',
        text: 'Review successfully submitted.'
      expect(page).to have_selector '.staff-review', count: 1
      within '.staff-review' do
        expect(page).to have_selector '.data .staff-name', text: staff.proper_name
        expect(page).to have_selector '.text p', text: 'This is my review.'
      end
    end
    context 'with an existing review' do
      it 'is possible to edit the text' do
        create :staff_review, user: staff, incident: incident
        visit incident_url(incident)
        within '.staff-review' do
          click_button 'Edit'
          fill_in 'Edit your review', with: 'This is a change.'
          click_button 'Save'
        end
        expect(page).to have_selector 'p.notice',
          text: 'Review successfully updated.'
        within '.staff-review' do
          expect(page).to have_selector '.text p', text: 'This is a change.'
        end
      end
      it 'is possible to remove the review' do
        create :staff_review, user: staff, incident: incident
        visit incident_url(incident)
        within '.staff-review' do
          click_button 'Delete'
        end
        expect(page).to have_selector 'p.notice',
          text: 'Review successfully removed.'
        expect(page).not_to have_selector '.staff-review'
      end
      context 'with a review belonging to someone else' do
        it 'cannot be edited or deleted' do
          create :staff_review, incident: incident # different user
          visit incident_url(incident)
          expect(page).not_to have_selector '.staff-review button', text: 'Edit'
          expect(page).not_to have_selector '.staff-review button', text: 'Delete'
        end
      end
    end
  end
end
