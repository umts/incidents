class AddPassengersInjuredInOtherVehicleToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :passengers_injured_in_other_vehicle, :integer, default: 0
  end
end
