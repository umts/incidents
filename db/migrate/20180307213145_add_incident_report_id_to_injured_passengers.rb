class AddIncidentReportIdToInjuredPassengers < ActiveRecord::Migration[5.1]
  def change
    add_column :injured_passengers, :incident_report_id, :integer
  end
end
