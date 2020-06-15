class AddOtherPassengerInformationTakenToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :other_passenger_information_taken, :boolean, default: false
  end
end
