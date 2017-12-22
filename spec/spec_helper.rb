# frozen_string_literal: true

require 'factory_bot_rails'
require 'simplecov'

SimpleCov.start 'rails'
SimpleCov.start do
  add_filter '/config/'
  add_filter '/spec/'
  refuse_coverage_drop
end

RSpec.configure do |config|
  config.order = :random
  config.include FactoryBot::Syntax::Methods
  config.before :all do
    FactoryBot.reload
  end
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
