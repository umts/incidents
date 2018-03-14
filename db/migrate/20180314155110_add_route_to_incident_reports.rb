class AddRouteToIncidentReports < ActiveRecord::Migration[5.1]
  def change
    add_column :incident_reports, :route, :string
  end
end
