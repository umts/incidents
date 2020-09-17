class RenamingColumnReasonTestCompleted < ActiveRecord::Migration[5.1]
  def change
    rename_column :supervisor_reports, :reason_test_completed, :test_status
  end
end
