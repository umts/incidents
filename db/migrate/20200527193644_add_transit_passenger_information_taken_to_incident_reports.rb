class AddTransitPassengerInformationTakenToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :transit_passenger_information_taken, :boolean
  end
end
