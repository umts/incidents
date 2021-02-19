# frozen_string_literal: true

require 'spec_helper'

describe 'logging in as a driver' do
  before(:each) { when_current_user_is driver }
  context 'with the default password' do
    let(:driver) { create :user, :driver, :default_password }
    it 'sends you where you want to go' do
      visit incidents_path
      expect(page).to have_current_path incidents_path
    end
  end
end

describe 'logging in with a deactivated account' do
  let!(:driver) { create :user, :driver, :default_password, active: false }
  it 'tells you that your account is deactivated' do
    visit root_path
    fill_in 'Badge number', with: driver.badge_number
    fill_in 'Password', with: driver.last_name
    click_button 'Log in'
    expect(page).to have_selector 'p.alert',
      text: 'Your account has been deactivated.'
  end
end
