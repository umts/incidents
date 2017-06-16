class RemoveIncidentIdFromSupervisorReports < ActiveRecord::Migration[5.1]
  def change
    remove_column :supervisor_reports, :incident_id, :integer
  end
end
