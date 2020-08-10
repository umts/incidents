class RenameCompletedDrugOrAlcoholTest < ActiveRecord::Migration[5.2]
  def change
      rename_column :supervisor_reports, :completed_drug_or_alcohol_test, :test_not_conducted
  end
end
