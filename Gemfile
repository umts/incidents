# frozen_string_literal: true

source 'https://rubygems.org'
ruby file: '.ruby-version'

gem 'bootsnap', require: false
gem 'bootstrap-sass', '~> 3.3'
gem 'coffee-rails'
gem 'csv'
gem 'devise'
gem 'haml-rails'
gem 'jbuilder'
gem 'mysql2'
gem 'nokogiri'
gem 'openssl'
gem 'paper_trail', '~> 15.1'
gem 'prawn-rails-forms'
gem 'puma'
gem 'rails', '~> 6.1.7'
gem 'sassc-rails'
gem 'turbolinks'

group :production do
  gem 'exception_notification'
  gem 'sidekiq', '~> 7.3'
  gem 'terser'
end

group :development do
  gem 'bcrypt_pbkdf', require: false
  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-pending', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-sidekiq', require: false
  gem 'ed25519', require: false
  gem 'haml_lint', require: false
  gem 'listen'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'web-console'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'pry-byebug'
  gem 'timecop'
end

group :test do
  gem 'capybara'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov'
end
