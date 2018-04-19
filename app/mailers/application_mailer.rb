# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'incidents@pvtaapps.com'
  layout 'mailer'

  def claims_export_error
    @incident, @cause = params[:incident], params[:cause]
    mail to: 'transit-it@admin.umass.edu',
      subject: "Claims export error"
  end

  def new_incident
    @incident = params[:incident]
    mail to: params[:destination],
         subject: "New incident for #{@incident.driver.full_name}"
  end
end
