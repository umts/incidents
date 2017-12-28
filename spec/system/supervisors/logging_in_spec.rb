# frozen_string_literal: true

require 'spec_helper'

describe 'logging in as a supervisor' do
  let(:supervisor) { create :user, :supervisor }
  before(:each) { when_current_user_is supervisor }
  context 'with the default password' do
    let(:supervisor) { create :user, :supervisor, :default_password }
    it 'requires a password change' do
      visit incidents_url
      expect(page).to have_text 'You must change your password from the default before continuing.'
      expect(page.current_url).to end_with change_password_path
    end
  end
  context 'with a normal password' do
    it 'sends you where you want to go' do
      visit incidents_url
      expect(page.current_url).to end_with incidents_path
    end
  end
end
