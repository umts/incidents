# frozen_string_literal: true

source 'https://rubygems.org'
ruby IO.read(File.expand_path('.ruby-version', __dir__)).strip

gem 'bootsnap'
gem 'bootstrap-sass', '~> 3.3'
gem 'coffee-rails', '~> 5.0'
gem 'csv'
gem 'devise'
gem 'haml-rails'
gem 'jbuilder', '~> 2.5'
gem 'mysql2'
gem 'nokogiri', '>= 1.8.1'
gem 'openssl'
gem 'paper_trail', '~> 10.3'
gem 'prawn-rails-forms', '~> 0.1.2'
gem 'puma', '~> 3.12'
gem 'rails', '~> 6.1.3'
gem 'sass-rails', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'

group :production do
  gem 'exception_notification', '~> 4.4.3'
  gem 'sidekiq', '~> 6.1.2'
end

group :development do
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0', require: false
  gem 'capistrano', '~> 3.14', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-pending', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-sidekiq', require: false
  gem 'ed25519', '>= 1.2', '< 2.0', require: false
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop'
  gem 'web-console', '>= 3.3.0'
end

group :development, :test do
  gem 'factory_bot_rails', '~> 4.8.2'
  gem 'ffaker', '~> 2.7.0'
  gem 'pry-byebug'
  gem 'timecop', '~> 0.9.1'
end

group :test do
  gem 'capybara'
  gem 'webdrivers', '~> 4.0'
  gem 'rspec-rails', '~> 3.7'
  gem 'simplecov', '~> 0.15'
end
