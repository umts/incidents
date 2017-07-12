class RemoveWitnessesFromSupervisorReports < ActiveRecord::Migration[5.1]
  def change
    remove_column :supervisor_reports, :witnesses, :text
  end
end
