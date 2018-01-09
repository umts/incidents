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

ActiveRecord::Schema.define(version: 20180109144332) do

  create_table "divisions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "divisions_users", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "division_id", null: false
    t.bigint "user_id", null: false
    t.index ["division_id", "user_id"], name: "index_divisions_users_on_division_id_and_user_id", unique: true
  end

  create_table "incident_reports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "run"
    t.string "block"
    t.string "bus"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "point_of_impact"
    t.integer "user_id"
    t.string "surface_type"
    t.string "surface_grade"
    t.integer "posted_speed_limit"
    t.boolean "credentials_exchanged", default: false
    t.boolean "summons_or_warning_issued", default: false
    t.text "summons_or_warning_info"
    t.integer "bus_distance_from_curb"
    t.datetime "occurred_at"
  end

  create_table "incidents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "driver_incident_report_id"
    t.integer "supervisor_incident_report_id"
    t.integer "supervisor_report_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed", default: false
    t.integer "reason_code_id"
    t.string "claim_number"
  end

  create_table "injured_passengers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "supervisor_report_id"
    t.string "name"
    t.text "address"
    t.string "nature_of_injury"
    t.boolean "transported_to_hospital"
    t.string "home_phone"
    t.string "cell_phone"
    t.string "work_phone"
  end

  create_table "reason_codes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "identifier"
    t.text "description"
  end

  create_table "staff_reviews", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "incident_id"
    t.integer "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "supervisor_reports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.boolean "pictures_saved"
    t.integer "saved_pictures"
    t.text "passenger_statement"
    t.datetime "faxed"
    t.boolean "completed_drug_or_alcohol_test"
    t.string "reason_test_completed"
    t.string "testing_facility"
    t.datetime "testing_facility_notified_at"
    t.datetime "employee_notified_of_test_at"
    t.datetime "employee_departed_to_test_at"
    t.datetime "employee_arrived_at_test_at"
    t.datetime "test_started_at"
    t.datetime "test_ended_at"
    t.datetime "employee_returned_at"
    t.datetime "superintendent_notified_at"
    t.datetime "program_manager_notified_at"
    t.datetime "director_notified_at"
    t.text "amplifying_comments"
    t.boolean "test_due_to_bodily_injury"
    t.boolean "test_due_to_disabling_damage"
    t.boolean "test_due_to_fatality"
    t.boolean "completed_drug_test"
    t.boolean "completed_alcohol_test"
    t.datetime "observation_made_at"
    t.boolean "test_due_to_employee_appearance"
    t.string "employee_appearance"
    t.boolean "test_due_to_employee_behavior"
    t.string "employee_behavior"
    t.boolean "test_due_to_employee_speech"
    t.string "employee_speech"
    t.boolean "test_due_to_employee_odor"
    t.string "employee_odor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "fta_threshold_not_met"
    t.boolean "driver_discounted"
    t.text "reason_threshold_not_met"
    t.text "reason_driver_discounted"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "staff", default: false
    t.string "badge_number"
    t.boolean "active", default: true
    t.boolean "supervisor", default: false
    t.integer "hastus_id"
    t.string "first_name"
    t.string "last_name"
    t.string "division"
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "password_changed_from_default", default: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "item_type", limit: 191, null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 4294967295
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "witnesses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "supervisor_report_id"
    t.string "name"
    t.text "address"
    t.boolean "onboard_bus"
    t.string "home_phone"
    t.string "cell_phone"
    t.string "work_phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
