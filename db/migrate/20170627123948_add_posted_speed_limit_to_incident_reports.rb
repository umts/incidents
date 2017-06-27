class AddPostedSpeedLimitToIncidentReports < ActiveRecord::Migration[5.1]
  def change
    add_column :incident_reports, :posted_speed_limit, :integer
  end
end
