class AddLatitudeAndLongitudeToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :latitude, :string
    add_column :incidents, :longitude, :string
  end
end
