class AddVideoPulledToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :video_pulled, :boolean
  end
end
