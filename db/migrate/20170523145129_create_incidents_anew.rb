class CreateIncidentsAnew < ActiveRecord::Migration[5.1]
  def change
    create_table :incidents do |t|
      t.integer :driver_id

      # Incident fields
      t.string :run
      t.string :block
      t.string :bus
      t.datetime :occurred_at
      t.integer :passengers_onboard
      t.integer :courtesy_cards_distributed
      t.integer :courtesy_cards_collected
      t.integer :speed
      t.string :location
      t.string :town
      t.string :weather_conditions
      t.string :road_conditions
      t.string :light_conditions
      t.boolean :headlights_used

      # Motor vehicle collision fields
      t.boolean :motor_vehicle_collision
      t.string :other_vehicle_plate
      t.string :other_vehicle_state
      t.string :other_vehicle_make
      t.string :other_vehicle_model
      t.string :other_vehicle_year
      t.string :other_vehicle_color
      t.integer :other_vehicle_passengers
      t.string :direction
      t.string :other_vehicle_direction
      t.string :other_driver_name
      t.string :other_driver_license_number
      t.string :other_driver_license_state
      t.string :other_vehicle_driver_address
      t.string :other_vehicle_driver_address_town
      t.string :other_vehicle_driver_address_state
      t.string :other_vehicle_driver_address_zip
      t.string :other_vehicle_driver_home_phone
      t.string :other_vehicle_driver_cell_phone
      t.string :other_vehicle_driver_work_phone
      t.boolean :other_vehicle_owned_by_other_driver
      t.string :other_vehicle_owner_name
      t.string :other_vehicle_owner_address
      t.string :other_vehicle_owner_address_town
      t.string :other_vehicle_owner_address_state
      t.string :other_vehicle_owner_address_zip
      t.string :other_vehicle_owner_home_phone
      t.string :other_vehicle_owner_cell_phone
      t.string :other_vehicle_owner_work_phone
      t.boolean :police_on_scene
      t.string :police_badge_number
      t.string :police_town_or_state
      t.string :police_case_assigned
      t.string :damage_to_bus_point_of_impact
      t.string :damage_to_other_vehicle_point_of_impact
      t.string :insurance_carrier
      t.string :insurance_policy_number
      t.date :insurance_effective_date

      # Passenger incident fields
      t.boolean :passenger_incident
      t.boolean :occurred_front_door
      t.boolean :occurred_rear_door
      t.boolean :occurred_front_steps
      t.boolean :occurred_rear_steps
      t.boolean :occurred_sudden_stop
      t.boolean :occurred_before_boarding
      t.boolean :occurred_while_boarding
      t.boolean :occurred_after_boarding
      t.boolean :occurred_while_exiting
      t.boolean :occurred_after_exiting
      t.string :motion_of_bus
      t.string :condition_of_steps
      t.boolean :bus_kneeled
      t.boolean :bus_up_to_curb
      t.string :reason_not_up_to_curb
      t.string :vehicle_in_bus_stop_plate
      t.text :injured_passengers

      t.text :description
      t.boolean :completed
      t.timestamps
    end
  end
end
