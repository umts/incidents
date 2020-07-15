class ChangeColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :supervisor_reports, :employee_returned_at, :employee_returned_to_work_or_released_from_duty_at
  end
end
