class SetIncidentReportBooleanDefaults < ActiveRecord::Migration[5.2]
  def change
    %i[
      incident_involved_a_van
      other_passenger_information_taken
      property_owner_information_taken
      assistance_requested
      chair_on_lift
      lift_deployed
    ].each do |column_name|
      change_column :incident_reports, column_name, :boolean, default: false
    end
  end
end
