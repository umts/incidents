class MoveOccurredAtToIncidentReports < ActiveRecord::Migration[5.1]
  def up
    add_column :incident_reports, :occurred_at, :datetime
    Incident.all.each do |inc|
      inc.driver_incident_report.update occurred_at: inc.occurred_at
      inc.supervisor_incident_report.try :update, occurred_at: inc.occurred_at
    end
    remove_column :incidents, :occurred_at, :datetime
  end

  def down
    add_column :incidents, :occurred_at, :datetime
    IncidentReport.all.each do |rep|
      rep.incident.update occurred_at: rep.occurred_at
    end
    remove_column :incident_reports, :occurred_at, :datetime
  end
end
