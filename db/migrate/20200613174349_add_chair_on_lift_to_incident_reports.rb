class AddChairOnLiftToIncidentReports < ActiveRecord::Migration[5.2]
  def change
    add_column :incident_reports, :chair_on_lift, :boolean
  end
end
