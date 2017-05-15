class ChangeDriverToDriverIdInIncidents < ActiveRecord::Migration[5.1]
  def change
    remove_column :incidents, :driver
    add_column :incidents, :driver_id, :integer
  end
end
