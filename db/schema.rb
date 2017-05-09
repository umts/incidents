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

ActiveRecord::Schema.define(version: 20170509150931) do

  create_table "incidents", force: :cascade do |t|
    t.string "driver"
    t.datetime "occurred_at"
    t.string "shift"
    t.string "route"
    t.string "vehicle"
    t.string "location"
    t.string "action_before"
    t.string "action_during"
    t.string "weather_conditions"
    t.string "light_conditions"
    t.string "road_conditions"
    t.boolean "camera_used"
    t.boolean "injuries"
    t.boolean "damage"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staff_reviews", force: :cascade do |t|
    t.integer "incident_id"
    t.integer "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
