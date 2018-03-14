class RemoveSupervisorReportIdFromInjuredPassengers < ActiveRecord::Migration[5.1]
  def change
    remove_column :injured_passengers, :supervisor_report_id, :integer
  end
end
