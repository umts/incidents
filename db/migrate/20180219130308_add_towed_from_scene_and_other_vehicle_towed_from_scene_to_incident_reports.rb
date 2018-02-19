class AddTowedFromSceneAndOtherVehicleTowedFromSceneToIncidentReports < ActiveRecord::Migration[5.1]
  def change
    add_column :incident_reports, :towed_from_scene, :boolean
    add_column :incident_reports, :other_vehicle_towed_from_scene, :boolean
  end
end
