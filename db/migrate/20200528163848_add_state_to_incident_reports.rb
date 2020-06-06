class AddStateToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :state, :string
  end
end
