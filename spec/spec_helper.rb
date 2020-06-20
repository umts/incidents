# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/config/'
  add_filter '/spec/'
  refuse_coverage_drop if ENV['CI']
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
if Rails.env.production?
  abort('The Rails environment is running in production mode!')
end

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

require 'rspec/rails'
require 'devise'
require 'factory_bot_rails'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.example_status_persistence_file_path =
    Rails.root.join('spec', 'examples.txt')

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

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

  config.before :each, js: true do
    driven_by :custom_headless_chrome
  end

  config.before :suite do
    Downloads.clear_downloads
  end
end

def fill_in_base_incident_fields
  select Time.now.strftime('%Y'), from: 'Year'
  select Time.now.strftime('%B'), from: 'Month'
  select Time.now.strftime('%-e'), from: 'Day'
  select Time.now.strftime('%I %p'), from: 'Hour'
  select Time.now.strftime('%m'), from: 'Minute'
  fill_in 'Bus #', with: '1803'
  fill_in 'Location', with: 'Mill and Locust'
  fill_in 'ZIP', with: '01108'
  select 'Springfield', from: 'Town'
  select 'North', from: 'Direction'
  fill_in 'Describe the incident in detail.',
    with: 'Lorem ipsum dolor sit amet.'
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
    loop do
      break if page.evaluate_script('jQuery.active').zero?
      rescue Selenium::WebDriver::Error::UnknownError
        raise "User doesn't have correct traits to access the page being tested."
    end
  end
end

def when_current_user_is(user)
  current_user = case user
                 when User, nil then user
                 when Symbol then create(:user, user)
                 end
  sign_in current_user
end
