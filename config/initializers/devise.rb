Devise.setup do |config|
  require 'devise/orm/active_record'

  config.mailer_sender = 'incidents@pvtaapps.com'
  config.authentication_keys = [:badge_number]
  config.strip_whitespace_keys = [:badge_number]
  config.stretches = Rails.env.test? ? 1 : 11
  config.timeout_in = 2.hours
  config.sign_out_via = :delete

  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
