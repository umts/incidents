# frozen_string_literal: true

source 'https://rubygems.org'
ruby file: '.ruby-version'

gem 'bootsnap', require: false
gem 'bootstrap-sass', '~> 3.3'
gem 'coffee-rails', '~> 5.0'
gem 'csv'
gem 'devise'
gem 'haml-rails'
gem 'jbuilder', '~> 2.5'

# Former default gem - dependency of prawn
# can be removed when prawn is updated to depend on it
gem 'matrix', '~> 0.4'

gem 'mysql2'
gem 'nokogiri', '>= 1.8.1'
gem 'openssl'
gem 'paper_trail', '~> 12.0'
gem 'prawn-rails-forms', '~> 0.1.2'
gem 'puma'
gem 'rails', '~> 6.1.3'
gem 'sassc-rails'
gem 'turbolinks', '~> 5'

group :production do
  gem 'exception_notification', '~> 4.4.3'
  gem 'sidekiq', '~> 7.0'
  gem 'terser'
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
  gem 'haml_lint', require: false
  gem 'listen'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
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
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov', '~> 0.15'
end
