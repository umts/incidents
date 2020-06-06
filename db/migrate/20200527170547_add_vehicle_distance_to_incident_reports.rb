class AddVehicleDistanceToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :vehicle_distance, :text
  end
end
