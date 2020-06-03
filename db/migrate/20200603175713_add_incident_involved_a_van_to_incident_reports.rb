class AddIncidentInvolvedAVanToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :incident_involved_a_van, :boolean, null: false
  end
end
