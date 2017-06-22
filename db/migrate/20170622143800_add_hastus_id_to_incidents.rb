class AddHastusIdToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :hastus_id, :integer
  end
end
