# frozen_string_literal: true

require 'test_helper'
require 'capybara/accessible'
require 'selenium-webdriver'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :accessible_selenium, using: :chrome, screen_size: [1024, 768]

  def take_failed_screenshot
    false
  end
end
