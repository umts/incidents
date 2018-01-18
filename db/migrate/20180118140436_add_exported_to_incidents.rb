class AddExportedToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :exported, :boolean, default: false
  end
end
