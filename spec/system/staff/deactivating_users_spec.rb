# frozen_string_literal: true

require 'spec_helper'

describe 'deactivating and reactivating users as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  it 'allows deactivating users', js: true do
    driver = create :user, :driver
    visit users_path
    click_button 'Drivers'
    # Only the one driver should be shown.
    expect(page).to have_text driver.last_name
    expect(page).to have_selector 'button',
                                  text: 'Deactivate', count: 1
    click_button 'Deactivate'
    expect(page).to have_selector 'p.notice',
                                  text: 'User was deactivated successfully.'
    # We should be on the main users page, but have only the current user.
    expect(page).to have_current_path users_path
    expect(page).to have_selector 'table.index tbody tr', count: 1
  end
  it 'allows reactivating users', js: true do
    create :user, :driver, active: false
    visit users_path(inactive: true)
    click_button 'Drivers'
    expect(page).to have_selector 'button',
                                  text: 'Reactivate', count: 1
    click_button 'Reactivate'
    expect(page).to have_selector 'p.notice',
                                  text: 'User was reactivated successfully.'
    # We should be on the main users page, and therefore see the current user
    # and the newly reactivated driver.
    expect(page).to have_current_path users_path
    expect(page).to have_selector 'table.index tbody tr', count: 2
  end
end
