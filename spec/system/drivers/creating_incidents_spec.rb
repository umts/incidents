# frozen_string_literal: true

require 'rails_helper'

describe 'creating incidents as a driver' do
  it 'brings drivers directly to the form' do
    visit incidents_url
    click_on 'New Incident'
  end
end
