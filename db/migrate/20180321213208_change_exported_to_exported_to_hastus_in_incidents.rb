class ChangeExportedToExportedToHastusInIncidents < ActiveRecord::Migration[5.1]
  def change
    rename_column :incidents, :exported, :exported_to_hastus
  end
end
