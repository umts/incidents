class AddCitationInformationTakenToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :citation_information_taken, :boolean
  end
end
