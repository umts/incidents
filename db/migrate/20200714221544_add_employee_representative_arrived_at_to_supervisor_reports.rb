class AddEmployeeRepresentativeArrivedAtToSupervisorReports < ActiveRecord::Migration[5.2]
  def change
    add_column :supervisor_reports, :employee_representative_arrived_at, :datetime
  end
end
