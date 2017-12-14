class RemoveHardDriveFieldsFromSupervisorReports < ActiveRecord::Migration[5.1]
  def change
    remove_column :supervisor_reports, :hard_drive_pulled, :boolean
    remove_column :supervisor_reports, :hard_drive_pulled_at, :datetime
    remove_column :supervisor_reports, :hard_drive_removed, :string
    remove_column :supervisor_reports, :hard_drive_replaced, :string
  end
end
