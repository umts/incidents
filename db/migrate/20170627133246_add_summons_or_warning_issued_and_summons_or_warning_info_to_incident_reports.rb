class AddSummonsOrWarningIssuedAndSummonsOrWarningInfoToIncidentReports < ActiveRecord::Migration[5.1]
  def change
    add_column :incident_reports, :summons_or_warning_issued, :boolean, default: false
    add_column :incident_reports, :summons_or_warning_info, :text
  end
end
