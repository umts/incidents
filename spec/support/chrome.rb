# frozen_string_literal: true

options = Selenium::WebDriver::Chrome::Options.new
options.add_preference(:plugins, always_open_pdf_externally: true)
options.add_preference(:download, default_directory: Downloads::PATH)

Capybara.register_driver :custom_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options).tap do |driver|
    driver.browser.download_path = Downloads::PATH
  end
end

Capybara.register_driver :custom_headless_chrome do |app|
  options.headless!

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options).tap do |driver|
    driver.browser.download_path = Downloads::PATH
  end
end
