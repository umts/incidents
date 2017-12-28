# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'simplecov'
SimpleCov.start 'rails'
SimpleCov.start do
  add_filter '/config/'
  add_filter '/spec/'
  refuse_coverage_drop if ENV['CI']
end

require 'rspec/rails'
require 'devise'
require 'factory_bot_rails'

ActiveRecord::Migration.maintain_test_schema!
RSpec.configure do |config|
  config.order = :random
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers
  config.before :all do
    FactoryBot.reload
  end
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end

def fill_in_base_incident_fields
  fill_in 'Bus #', with: '1803'
  fill_in 'Location', with: 'Mill and Locust'
  select 'Springfield', from: 'Town'
end

def when_current_user_is(user)
  current_user = case user
                 when User, nil then user
                 when Symbol then create(:user, user)
                 end
  sign_in current_user
end
