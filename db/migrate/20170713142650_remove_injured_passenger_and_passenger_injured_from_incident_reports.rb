class RemoveInjuredPassengerAndPassengerInjuredFromIncidentReports < ActiveRecord::Migration[5.1]
  def change
    remove_column :incident_reports, :injured_passenger, :text
    remove_column :incident_reports, :passenger_injured, :boolean
  end
end
