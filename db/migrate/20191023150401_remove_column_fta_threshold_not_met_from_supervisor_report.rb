class RemoveColumnFtaThresholdNotMetFromSupervisorReport < ActiveRecord::Migration[5.1]
  def change
    remove_column :supervisor_reports, :fta_threshold_not_met, :boolean
  end
end
