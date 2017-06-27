class AddSurfaceTypeAndSurfaceGradeToIncidentReports < ActiveRecord::Migration[5.1]
  def change
    add_column :incident_reports, :surface_type, :string
    add_column :incident_reports, :surface_grade, :string
  end
end
