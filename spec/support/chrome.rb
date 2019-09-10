# frozen_string_literal: true

require 'capybara/rspec'
require 'selenium/webdriver'

DOWNLOAD_DIR = Rails.root.join('spec', 'downloads')

options = Selenium::WebDriver::Chrome::Options.new
options.add_preference(:download, prompt_for_download: false,
                                  default_directory: DOWNLOAD_DIR)
options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })

Capybara.register_driver :custom_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.register_driver :custom_headless_chrome do |app|
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1280,800')

  driver = Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)

  ### Allow file downloads in Google Chrome when headless!!!
  ### https://bugs.chromium.org/p/chromium/issues/detail?id=696481#c89
  bridge = driver.browser.send(:bridge)

  path = "/session/#{bridge.session_id}/chromium/send_command"

  bridge.http.call(:post, path, cmd: 'Page.setDownloadBehavior',
                                params: {
                                  behavior: 'allow',
                                  downloadPath: DOWNLOAD_DIR
                                })
  driver
end
