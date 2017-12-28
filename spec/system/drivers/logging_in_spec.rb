# frozen_string_literal: true

require 'spec_helper'

describe 'logging in as a driver' do
  before(:each) { when_current_user_is driver }
  context 'with the default password' do
    let(:driver) { create :user, :driver, :default_password }
    it 'sends you where you want to go' do
      visit incidents_url
      expect(page.current_url).to end_with incidents_path
    end
  end
end
