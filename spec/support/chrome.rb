# frozen_string_literal: true

DOWNLOAD_DIR = Rails.root.join('spec', 'downloads')

Capybara.register_driver :custom_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome).tap do |driver|
    driver.browser.download_path = DOWNLOAD_DIR
  end
end

Capybara.register_driver :custom_headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.headless!

  Capybara::Selenium::Driver.new( app, browser: :chrome, options: options).tap do |driver|
    driver.browser.download_path = DOWNLOAD_DIR
  end
end
