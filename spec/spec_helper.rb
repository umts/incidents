# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  maximum_coverage_drop 0.5 if ENV['CI']
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?

Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

require 'rspec/rails'
require 'rspec/retry'
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

  config.verbose_retry = true
  config.display_try_failure_messages = true

  config.around :each, :js do |example|
    example.run_with_retry retry: 5
  end

  config.retry_callback = proc do |example|
    if example.metadata[:js]
      Capybara.reset!
    end
  end

  config.before :each, type: :system do
    driven_by :rack_test
  end
  config.before :each, type: :system, js: true do
    driven_by :selenium, using: :headless_chrome do |options|
      options.add_preference 'plugins.always_open_pdf_externally', true
    end
  end
end

def fill_in_base_incident_fields
  fill_in_date_and_time
  fill_in 'Bus #', with: '1803'
  fill_in 'Location', with: 'Mill and Locust'
  fill_in 'ZIP', with: '01108'
  select 'Springfield', from: 'Town'
  select 'North', from: 'Direction bus'
  fill_in 'Describe the incident in detail.',
          with: 'Lorem ipsum dolor sit amet.'
end

def fill_in_date_and_time
  select Time.now.strftime('%Y'), from: 'Year'
  select Time.now.strftime('%B'), from: 'Month'
  select Time.now.strftime('%-e'), from: 'Day'
  select Time.now.strftime('%I %p'), from: 'Hour'
  select Time.now.strftime('%m'), from: 'Minute'
end

def incident_in_divisions(divisions, *traits)
  attributes = if traits.last.is_a? Hash
                 traits.pop
               else {}
               end
  driver = create :user, :driver, divisions: divisions
  report = create :incident_report, user: driver
  create :incident, *traits, attributes.merge(driver_incident_report: report)
end

def save_and_preview
  accept_alert do
    click_on 'Save report and preview PDF'
  end
end

def when_current_user_is(user)
  current_user = case user
                 when User, nil then user
                 when Symbol then create(:user, user)
                 end
  sign_in current_user
end
