class AddLiftDeployedToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :lift_deployed, :boolean, null: false
  end
end
