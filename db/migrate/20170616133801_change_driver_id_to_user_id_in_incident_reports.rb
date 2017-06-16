class ChangeDriverIdToUserIdInIncidentReports < ActiveRecord::Migration[5.1]
  def change
    remove_column :incident_reports, :driver_id, :integer
    add_column :incident_reports, :user_id, :integer
  end
end
