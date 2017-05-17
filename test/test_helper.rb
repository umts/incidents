require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include Devise::Test::IntegrationHelpers

  def when_current_user_is(user)
    current_user =
      case user
      when Symbol then create :user, user
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
    create :incident, attrs.merge(driver: user)
  end
end
