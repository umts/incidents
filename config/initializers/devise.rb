Devise.setup do |config|
  require 'devise/orm/active_record'

  config.mailer_sender = 'incidents@pvtaapps.com'
  config.authentication_keys = [:badge_number]
  config.strip_whitespace_keys = [:badge_number]
  config.stretches = Rails.env.test? ? 1 : 11
  config.timeout_in = 1.hour
  config.sign_out_via = :delete
end
