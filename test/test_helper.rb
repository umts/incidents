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
end
