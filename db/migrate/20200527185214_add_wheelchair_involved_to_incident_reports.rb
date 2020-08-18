class AddWheelchairInvolvedToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :wheelchair_involved, :boolean, default: false
  end
end
