class RemoveTestNotConductedFromSupervisorReports < ActiveRecord::Migration[5.1]
  def change
    remove_column :supervisor_reports, :test_not_conducted, :boolean
  end
end
