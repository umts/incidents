class AddOccurredAtToIncidents < ActiveRecord::Migration[5.2]
  def change
    add_column :incidents, :occurred_at, :datetime
  end
end
