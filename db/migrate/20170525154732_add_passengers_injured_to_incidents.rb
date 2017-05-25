class AddPassengersInjuredToIncidents < ActiveRecord::Migration[5.1]
  def change
    add_column :incidents, :passengers_injured, :boolean, default: false
  end
end
