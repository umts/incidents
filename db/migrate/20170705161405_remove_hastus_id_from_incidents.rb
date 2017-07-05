class RemoveHastusIdFromIncidents < ActiveRecord::Migration[5.1]
  def change
    remove_column :incidents, :hastus_id, :integer
  end
end
