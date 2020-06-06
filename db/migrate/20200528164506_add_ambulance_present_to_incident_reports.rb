class AddAmbulancePresentToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :ambulance_present, :boolean, default: false
  end
end
