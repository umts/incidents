# frozen_string_literal: true

require 'spec_helper'

describe 'logging in as staff' do
  let(:staff) { create :user, :staff }
  before(:each) { when_current_user_is staff }
  context 'with the default password' do
    let(:staff) { create :user, :staff, :default_password }
    it 'requires a password change' do
      visit root_path
      expect(page).to have_text 'You must change your password from the default before continuing.'
      expect(page).to have_current_path change_password_path
    end
  end
  context 'with a normal password' do
    it 'sends you where you want to go' do
      visit users_path # not root
      expect(page).to have_current_path users_path
    end
  end
end
