# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'incidents-noreply@pvta.com'
  layout 'mailer'

  def new_incident
    @incident = params[:incident]
    mail to: params[:destination],
      subject: "New incident for #{@incident.driver.full_name}"
  end
end
