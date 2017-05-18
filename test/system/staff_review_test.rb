# frozen_string_literal: true

require 'application_system_test_case'

class StaffReviewTest < ApplicationSystemTestCase
  test 'staff members can add staff reviews to an incident' do
    incident = create :incident
    staff_member = create :user, :staff
    when_current_user_is staff_member
    visit incident_url(incident)

    assert_selector 'form.new-review'

    within 'form.new-review' do
      fill_in 'staff_review[text]',
              with: 'This is my awesome review of this incident.'
      Timecop.freeze Time.zone.local(2017, 5, 17, 12, 4) do
        click_button 'Create staff review'
      end
    end

    assert_selector '.staff-review'
    within '.staff-review' do
      assert_selector '.staff-name', text: staff_member.name
      assert_selector '.time', text: 'Wednesday, May 17 12:04 pm'
      assert_selector '.text',
                      text: 'This is my awesome review of this incident.'
    end
  end

  test 'staff members can edit their existing staff reviews' do
    review = create :staff_review
    when_current_user_is review.user
    visit incident_url(review.incident)

    within '.staff-review' do
      assert_selector '.text',            visible: true
      assert_selector 'a.delete',         visible: true
      assert_selector 'button.edit',      visible: true
      assert_selector 'form.edit-review', visible: false

      click_button 'Edit'

      assert_selector '.text',            visible: false
      assert_selector 'a.delete',         visible: false
      assert_selector 'button.edit',      visible: false
      assert_selector 'form.edit-review', visible: true

      within 'form.edit-review' do
        fill_in 'staff_review[text]', with: 'This is my edited review text.'
        click_button 'Save'
      end
    end

    assert_selector '.staff-review .text',
                    text: 'This is my edited review text.'
  end

  test 'staff members cannot edit the reviews of others' do
    review = create :staff_review
    when_current_user_is :staff
    visit incident_url(review.incident)

    assert_no_selector '.staff-review form.edit-review'
  end

  test 'staff members can delete their own reviews' do
    review = create :staff_review
    when_current_user_is review.user
    visit incident_url(review.incident)

    within('.staff-review') { click_button 'Delete' }

    assert_no_selector '.staff-review'
  end

  test 'staff members cannot delete the reviews of others' do
    review = create :staff_review
    when_current_user_is :staff
    visit incident_url(review.incident)

    assert_no_selector '.staff-review button.delete'
  end

  test 'drivers cannot add staff reviews to an incident' do
    incident = create :incident
    when_current_user_is incident.driver
    visit incident_url(incident)

    assert_no_selector 'form.new-review'
  end
end
