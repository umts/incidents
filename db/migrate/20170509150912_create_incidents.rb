# frozen_string_literal: true

class CreateIncidents < ActiveRecord::Migration[5.1]
  def change
    create_table :incidents do |t|
      t.string :driver
      t.datetime :occurred_at
      t.string :shift
      t.string :route
      t.string :vehicle
      t.string :location
      t.string :action_before
      t.string :action_during
      t.string :weather_conditions
      t.string :light_conditions
      t.string :road_conditions
      t.boolean :camera_used
      t.boolean :injuries
      t.boolean :damage
      t.text :description

      t.timestamps
    end
  end
end
