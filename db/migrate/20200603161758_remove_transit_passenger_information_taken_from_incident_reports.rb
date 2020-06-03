class RemoveTransitPassengerInformationTakenFromIncidentReports < ActiveRecord::Migration[5.2]
  def change
    remove_column :incident_reports, :transit_passenger_information_taken, :boolean
  end
end
