class AddCredentialsExchangedToIncidentReports < ActiveRecord::Migration[5.1]
  def change
    add_column :incident_reports, :credentials_exchanged, :boolean, default: false
  end
end
