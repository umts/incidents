class AddBusDistanceFromCurbToIncidentReports < ActiveRecord::Migration[5.1]
  def change
    add_column :incident_reports, :bus_distance_from_curb, :integer
  end
end
