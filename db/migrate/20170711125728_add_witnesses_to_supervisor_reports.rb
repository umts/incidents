class AddWitnessesToSupervisorReports < ActiveRecord::Migration[5.1]
  def change
    add_column :supervisor_reports, :witnesses, :text
  end
end
