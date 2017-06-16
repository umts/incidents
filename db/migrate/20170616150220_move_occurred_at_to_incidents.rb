class MoveOccurredAtToIncidents < ActiveRecord::Migration[5.1]
  def change
    remove_column :incident_reports, :occurred_at, :datetime
    add_column :incidents, :occurred_at, :datetime
  end
end
