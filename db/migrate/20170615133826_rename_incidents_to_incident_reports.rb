class RenameIncidentsToIncidentReports < ActiveRecord::Migration[5.1]
  def change
    rename_table :incidents, :incident_reports
  end
end
