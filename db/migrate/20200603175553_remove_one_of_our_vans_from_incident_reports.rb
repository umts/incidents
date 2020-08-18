class RemoveOneOfOurVansFromIncidentReports < ActiveRecord::Migration[5.2]
  def change
    remove_column :incident_reports, :one_of_our_vans, :boolean
  end
end
