class RemoveDescriptionFromSupervisorReports < ActiveRecord::Migration[5.1]
  def change
    remove_column :supervisor_reports, :description, :text
  end
end
