class AddOneOfOurVansToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :one_of_our_vans, :boolean, default: false
  end
end
