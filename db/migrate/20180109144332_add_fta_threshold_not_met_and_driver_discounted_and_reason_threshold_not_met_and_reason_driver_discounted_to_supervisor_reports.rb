class AddFtaThresholdNotMetAndDriverDiscountedAndReasonThresholdNotMetAndReasonDriverDiscountedToSupervisorReports < ActiveRecord::Migration[5.1]
  def change
    add_column :supervisor_reports, :fta_threshold_not_met, :boolean
    add_column :supervisor_reports, :driver_discounted, :boolean
    add_column :supervisor_reports, :reason_threshold_not_met, :text
    add_column :supervisor_reports, :reason_driver_discounted, :text
  end
end
