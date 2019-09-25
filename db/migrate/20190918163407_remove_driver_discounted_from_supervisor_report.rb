class RemoveDriverDiscountedFromSupervisorReport < ActiveRecord::Migration[5.1]
  def change
    remove_column :supervisor_reports, :driver_discounted, :boolean
  end
end
