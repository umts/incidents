class AddAssistanceRequestedToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :assistance_requested, :boolean, null: false
  end
end
