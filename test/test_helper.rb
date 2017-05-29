# frozen_string_literal: true

require 'simplecov'

SimpleCov.start 'rails' do
  %w[channels config jobs lib/extensions mailers].each do |dir|
    add_filter "/#{dir}/"
  end
  add_filter '/app/models/application_record.rb'
end

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Devise::Test::IntegrationHelpers

  def when_current_user_is(user)
    current_user =
      case user
      when Symbol then create :user, user
      when String then User.find_by name: user
      when User then user
      when nil then nil
      else raise ArgumentError, 'Invalid user type'
      end
    sign_in current_user
  end

  def incident_for(driver, attrs = {})
    user =
      case driver
      when String then create :user, :driver, name: driver
      when User then driver
      else raise ArgumentError, 'Invalid user type'
      end
    case attrs
    when Hash
      create :incident, attrs.merge(driver: user)
    when Symbol
      create :incident, attrs, driver: user
    end
  end

  def assert_incident_for(driver_name)
    assert_selector 'table.incidents td', text: driver_name
  end

  def assert_no_incident_for(driver_name)
    assert_no_selector 'table.incidents td', text: driver_name
  end
end
