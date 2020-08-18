class AddPropertyOwnerInformationTakenToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :property_owner_information_taken, :boolean
  end
end
