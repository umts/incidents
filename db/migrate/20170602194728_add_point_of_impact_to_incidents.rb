class AddPointOfImpactToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :point_of_impact, :string
  end
end
