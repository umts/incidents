class MoveCompletedFromIncidentReportsToIncidents < ActiveRecord::Migration[5.1]
  def change
    remove_column :incident_reports, :completed, :boolean
    add_column :incidents, :completed, :boolean
  end
end
