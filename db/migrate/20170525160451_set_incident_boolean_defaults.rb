class SetIncidentBooleanDefaults < ActiveRecord::Migration[5.1]
  def change
    %i[
      headlights_used
      motor_vehicle_collision
      other_vehicle_owned_by_other_driver
      police_on_scene
      passenger_incident
      occurred_front_door
      occurred_rear_door
      occurred_front_steps
      occurred_rear_steps
      occurred_sudden_stop
      occurred_before_boarding
      occurred_while_boarding
      occurred_after_boarding
      occurred_while_exiting
      occurred_after_exiting
      bus_kneeled
      bus_up_to_curb
      passenger_injured
      completed
    ].each do |column_name|
      change_column :incidents, column_name, :boolean, default: false
    end
  end
end
