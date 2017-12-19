Devise.setup do |config|
  require 'devise/orm/active_record'

  config.mailer_sender = 'incidents@pvtaapps.com'
  config.authentication_keys = [:last_name]
  config.case_insensitive_keys = [:last_name]
  config.strip_whitespace_keys = [:last_name]
  config.stretches = Rails.env.test? ? 1 : 11
  config.timeout_in = 30.minutes
  config.reset_password_keys = [:last_name]
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
end
