class RemoveCitationInformationTakenFromIncidentReports < ActiveRecord::Migration[5.2]
  def change
    remove_column :incident_reports, :citation_information_taken, :boolean
  end
end
