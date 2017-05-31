# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170531190338) do

  create_table "incidents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "driver_id"
    t.string "run"
    t.string "block"
    t.string "bus"
    t.datetime "occurred_at"
    t.integer "passengers_onboard"
    t.integer "courtesy_cards_distributed"
    t.integer "courtesy_cards_collected"
    t.integer "speed"
    t.string "location"
    t.string "town"
    t.string "weather_conditions"
    t.string "road_conditions"
    t.string "light_conditions"
    t.boolean "headlights_used", default: false
    t.boolean "motor_vehicle_collision", default: false
    t.string "other_vehicle_plate"
    t.string "other_vehicle_state"
    t.string "other_vehicle_make"
    t.string "other_vehicle_model"
    t.string "other_vehicle_year"
    t.string "other_vehicle_color"
    t.integer "other_vehicle_passengers"
    t.string "direction"
    t.string "other_vehicle_direction"
    t.string "other_driver_name"
    t.string "other_driver_license_number"
    t.string "other_driver_license_state"
    t.string "other_vehicle_driver_address"
    t.string "other_vehicle_driver_address_town"
    t.string "other_vehicle_driver_address_state"
    t.string "other_vehicle_driver_address_zip"
    t.string "other_vehicle_driver_home_phone"
    t.string "other_vehicle_driver_cell_phone"
    t.string "other_vehicle_driver_work_phone"
    t.boolean "other_vehicle_owned_by_other_driver", default: false
    t.string "other_vehicle_owner_name"
    t.string "other_vehicle_owner_address"
    t.string "other_vehicle_owner_address_town"
    t.string "other_vehicle_owner_address_state"
    t.string "other_vehicle_owner_address_zip"
    t.string "other_vehicle_owner_home_phone"
    t.string "other_vehicle_owner_cell_phone"
    t.string "other_vehicle_owner_work_phone"
    t.boolean "police_on_scene", default: false
    t.string "police_badge_number"
    t.string "police_town_or_state"
    t.string "police_case_assigned"
    t.string "damage_to_bus_point_of_impact"
    t.string "damage_to_other_vehicle_point_of_impact"
    t.string "insurance_carrier"
    t.string "insurance_policy_number"
    t.date "insurance_effective_date"
    t.boolean "passenger_incident", default: false
    t.boolean "occurred_front_door", default: false
    t.boolean "occurred_rear_door", default: false
    t.boolean "occurred_front_steps", default: false
    t.boolean "occurred_rear_steps", default: false
    t.boolean "occurred_sudden_stop", default: false
    t.boolean "occurred_before_boarding", default: false
    t.boolean "occurred_while_boarding", default: false
    t.boolean "occurred_after_boarding", default: false
    t.boolean "occurred_while_exiting", default: false
    t.boolean "occurred_after_exiting", default: false
    t.string "motion_of_bus"
    t.string "condition_of_steps"
    t.boolean "bus_kneeled", default: false
    t.boolean "bus_up_to_curb", default: false
    t.string "reason_not_up_to_curb"
    t.string "vehicle_in_bus_stop_plate"
    t.text "description"
    t.boolean "completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "passenger_injured", default: false
    t.text "injured_passenger"
  end

  create_table "staff_reviews", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "incident_id"
    t.integer "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "staff", default: false
    t.string "badge_number"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "item_type", limit: 191, null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 4294967295
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

end
