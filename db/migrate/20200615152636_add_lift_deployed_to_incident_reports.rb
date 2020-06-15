class AddLiftDeployedToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :lift_deployed, :boolean, default: false
  end
end
