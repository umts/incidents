class SupportSingleInjuredPassenger < ActiveRecord::Migration[5.1]
  def change
    remove_column :incidents, :passengers_injured
    remove_column :incidents, :injured_passengers

    add_column :incidents, :passenger_injured, :boolean, default: false
    add_column :incidents, :injured_passenger, :text
  end
end
