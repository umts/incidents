class ChangeIncidentReportBooleanDefaults < ActiveRecord::Migration[5.2]
  def change
    %i[
      incident_involved_a_van
      assistance_requested
      chair_on_lift
      lift_deployed
    ].each do |column_name|
      change_column_null :incident_reports, column_name, true
    end
  end
end
