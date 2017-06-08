# frozen_string_literal: true

require 'test_helper'
require 'capybara/accessible'
require 'selenium-webdriver'

Capybara::Accessible::Auditor.severe_rules = [
  'AX_HTML_01',  # The web page must have the content's human language must be
                 # indicated in the markup
  'AX_HTML_02',  # An element's ID must be unique in the DOM
  'AX_TEXT_01',  # Controls and media elements should have labels
  'AX_TEXT_02',  # Images should have an alt attribute, unless they have an ARIA
                 # role of 'presentation'
  'AX_FOCUS_03', # Avoid positive integer values for tabindex
  'AX_COLOR_01', # Text elements should have a reasonable contrast ratio
  'AX_TABLE_01', # Tables must have appropriate headers
]

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :accessible_selenium, using: :firefox, screen_size: [1024, 768]

  def take_failed_screenshot
    false
  end
end
