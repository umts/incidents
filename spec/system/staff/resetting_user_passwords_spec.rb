# frozen_string_literal: true

require 'spec_helper'

describe 'resetting user passwords', js: true do
  before(:each) { when_current_user_is :staff }
  let!(:user) { create :user, :driver }

  it 'allows resetting users passwords to the default' do
    visit users_url
    click_button 'Drivers'
    expect(page).to have_selector 'button',
      text: 'Reset Password', count: 1

    click_button 'Reset Password'
    expect(page).to have_selector 'p.notice',
      text: 'password was reset to the default password'

    expect(user.reload.valid_password? user.last_name).to be true
  end
end
