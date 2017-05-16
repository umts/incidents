class AddCompletedToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :completed, :boolean, default: false
  end
end
