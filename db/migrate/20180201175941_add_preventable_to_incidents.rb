class AddPreventableToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :preventable, :boolean
  end
end
