class AddZipToIncidentReports < ActiveRecord::Migration[5.1]
  def change
    add_column :incident_reports, :zip, :string
  end
end
