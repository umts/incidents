# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_13_155826) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "divisions", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "claims_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "divisions_users", id: false, charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "division_id", null: false
    t.bigint "user_id", null: false
    t.index ["division_id", "user_id"], name: "index_divisions_users_on_division_id_and_user_id", unique: true
  end

  create_table "incident_reports", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "ambulance_present", default: false
    t.boolean "assistance_requested", default: false, null: false
    t.string "block"
    t.string "bus"
    t.integer "bus_distance_from_curb"
    t.boolean "bus_kneeled", default: false
    t.boolean "bus_up_to_curb", default: false
    t.boolean "chair_on_lift", default: false, null: false
    t.string "condition_of_steps"
    t.integer "courtesy_cards_collected"
    t.integer "courtesy_cards_distributed"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "credentials_exchanged", default: false
    t.string "damage_to_bus_point_of_impact"
    t.string "damage_to_other_vehicle_point_of_impact"
    t.text "description"
    t.string "direction"
    t.boolean "headlights_used", default: false
    t.boolean "incident_involved_a_van", default: false, null: false
    t.string "insurance_carrier"
    t.date "insurance_effective_date"
    t.string "insurance_policy_number"
    t.boolean "lift_deployed", default: false, null: false
    t.string "light_conditions"
    t.string "location"
    t.string "motion_of_bus"
    t.boolean "motor_vehicle_collision", default: false
    t.boolean "occurred_after_boarding", default: false
    t.boolean "occurred_after_exiting", default: false
    t.datetime "occurred_at", precision: nil
    t.boolean "occurred_before_boarding", default: false
    t.boolean "occurred_front_door", default: false
    t.boolean "occurred_front_steps", default: false
    t.boolean "occurred_rear_door", default: false
    t.boolean "occurred_rear_steps", default: false
    t.boolean "occurred_sudden_stop", default: false
    t.boolean "occurred_while_boarding", default: false
    t.boolean "occurred_while_exiting", default: false
    t.string "other_driver_license_number"
    t.string "other_driver_license_state"
    t.string "other_driver_name"
    t.boolean "other_passenger_information_taken", default: false
    t.string "other_vehicle_color"
    t.string "other_vehicle_direction"
    t.string "other_vehicle_driver_address"
    t.string "other_vehicle_driver_address_state"
    t.string "other_vehicle_driver_address_town"
    t.string "other_vehicle_driver_address_zip"
    t.string "other_vehicle_driver_cell_phone"
    t.string "other_vehicle_driver_home_phone"
    t.string "other_vehicle_driver_work_phone"
    t.string "other_vehicle_make"
    t.string "other_vehicle_model"
    t.boolean "other_vehicle_owned_by_other_driver", default: false
    t.string "other_vehicle_owner_address"
    t.string "other_vehicle_owner_address_state"
    t.string "other_vehicle_owner_address_town"
    t.string "other_vehicle_owner_address_zip"
    t.string "other_vehicle_owner_cell_phone"
    t.string "other_vehicle_owner_home_phone"
    t.string "other_vehicle_owner_name"
    t.string "other_vehicle_owner_work_phone"
    t.integer "other_vehicle_passengers"
    t.string "other_vehicle_plate"
    t.string "other_vehicle_state"
    t.boolean "other_vehicle_towed_from_scene"
    t.string "other_vehicle_year"
    t.boolean "passenger_incident", default: false
    t.integer "passengers_onboard"
    t.string "point_of_impact"
    t.string "police_badge_number"
    t.string "police_case_assigned"
    t.boolean "police_on_scene", default: false
    t.string "police_town_or_state"
    t.integer "posted_speed_limit"
    t.boolean "property_owner_information_taken", default: false
    t.boolean "pvta_passenger_information_taken", default: false
    t.string "reason_not_up_to_curb"
    t.string "road_conditions"
    t.string "route"
    t.string "run"
    t.integer "speed"
    t.string "state"
    t.text "summons_or_warning_info"
    t.boolean "summons_or_warning_issued", default: false
    t.string "surface_grade"
    t.string "surface_type"
    t.boolean "towed_from_scene"
    t.string "town"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
    t.text "vehicle_distance"
    t.string "vehicle_in_bus_stop_plate"
    t.string "weather_conditions"
    t.boolean "wheelchair_involved", default: false
    t.string "zip"
  end

  create_table "incidents", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "claim_number"
    t.integer "claims_id"
    t.boolean "completed", default: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "driver_incident_report_id"
    t.boolean "exported_to_claims"
    t.boolean "exported_to_hastus", default: false
    t.string "latitude"
    t.string "longitude"
    t.boolean "preventable"
    t.integer "reason_code_id"
    t.text "root_cause_analysis"
    t.string "second_reason_code"
    t.integer "supervisor_incident_report_id"
    t.integer "supervisor_report_id"
    t.integer "supplementary_reason_code_id"
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "video_pulled"
  end

  create_table "injured_passengers", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "address"
    t.string "cell_phone"
    t.string "home_phone"
    t.integer "incident_report_id"
    t.string "name"
    t.string "nature_of_injury"
    t.boolean "transported_to_hospital"
    t.string "work_phone"
  end

  create_table "reason_codes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "description"
    t.string "identifier"
  end

  create_table "staff_reviews", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "incident_id"
    t.text "text"
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
  end

  create_table "supervisor_reports", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "amplifying_comments"
    t.boolean "completed_alcohol_test"
    t.boolean "completed_drug_or_alcohol_test"
    t.boolean "completed_drug_test"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "director_notified_at", precision: nil
    t.string "employee_appearance"
    t.datetime "employee_arrived_at_test_at", precision: nil
    t.string "employee_behavior"
    t.datetime "employee_departed_to_test_at", precision: nil
    t.datetime "employee_notified_of_test_at", precision: nil
    t.string "employee_odor"
    t.datetime "employee_representative_arrived_at", precision: nil
    t.datetime "employee_representative_notified_at", precision: nil
    t.datetime "employee_returned_to_work_or_released_from_duty_at", precision: nil
    t.string "employee_speech"
    t.datetime "faxed", precision: nil
    t.datetime "observation_made_at", precision: nil
    t.text "passenger_statement"
    t.boolean "pictures_saved"
    t.datetime "program_manager_notified_at", precision: nil
    t.text "reason_driver_discounted"
    t.text "reason_threshold_not_met"
    t.integer "saved_pictures"
    t.datetime "superintendent_notified_at", precision: nil
    t.boolean "test_due_to_bodily_injury"
    t.boolean "test_due_to_disabling_damage"
    t.boolean "test_due_to_employee_appearance"
    t.boolean "test_due_to_employee_behavior"
    t.boolean "test_due_to_employee_odor"
    t.boolean "test_due_to_employee_speech"
    t.boolean "test_due_to_fatality"
    t.datetime "test_ended_at", precision: nil
    t.datetime "test_started_at", precision: nil
    t.string "test_status"
    t.string "testing_facility"
    t.datetime "testing_facility_notified_at", precision: nil
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "supplementary_reason_codes", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "description"
    t.string "identifier"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "badge_number"
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "password_changed_from_default", default: false
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.boolean "staff", default: false
    t.boolean "supervisor", default: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "event", null: false
    t.integer "item_id", null: false
    t.string "item_type", limit: 191, null: false
    t.text "object", size: :long, collation: "utf8mb4_bin"
    t.text "object_changes", size: :long, collation: "utf8mb4_bin"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.check_constraint "json_valid(`object_changes`)", name: "object_changes"
    t.check_constraint "json_valid(`object`)", name: "object"
  end

  create_table "witnesses", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.text "address"
    t.string "cell_phone"
    t.datetime "created_at", precision: nil, null: false
    t.string "home_phone"
    t.string "name"
    t.boolean "onboard_bus"
    t.integer "supervisor_report_id"
    t.datetime "updated_at", precision: nil, null: false
    t.string "work_phone"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
