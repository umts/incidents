class RemoveUserIdFromSupervisorReports < ActiveRecord::Migration[5.1]
  def change
    remove_column :supervisor_reports, :user_id, :integer
  end
end
