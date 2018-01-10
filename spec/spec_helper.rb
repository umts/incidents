# frozen_string_literal: true
#
require 'simplecov'
SimpleCov.start 'rails'
SimpleCov.start do
  add_filter '/config/'
  add_filter '/spec/'
  refuse_coverage_drop if ENV['CI']
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'rspec/retry'
require 'devise'
require 'factory_bot_rails'

ActiveRecord::Migration.maintain_test_schema!
Capybara.default_driver = :selenium
RSpec.configure do |config|
  config.order = :random
  config.verbose_retry = true
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.before :all do
    FactoryBot.reload
  end
  config.around :each do |example|
    example.run_with_retry retry: 3
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

def incident_in_divisions(divisions, *traits)
  attributes = if traits.last.is_a? Hash
                 traits.pop
               else Hash.new
               end
  driver = create :user, :driver, divisions: divisions
  report = create :incident_report, user: driver
  create :incident, *traits, attributes.merge(driver_incident_report: report)
end

# source: https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
def wait_for_ajax!
  Timeout.timeout Capybara.default_max_wait_time do
    loop until page.evaluate_script('jQuery.active').zero?
  end
  sleep 1.0 if RSpec.current_example.attempts > 0
end

def wait_for_animation!
  if RSpec.current_example.attempts.zero?
    sleep 0.5
  else sleep 1.0
  end
end

def when_current_user_is(user)
  current_user = case user
                 when User, nil then user
                 when Symbol then create(:user, user)
                 end
  sign_in current_user
end
