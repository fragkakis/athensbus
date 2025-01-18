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

ActiveRecord::Schema[8.0].define(version: 2025_01_18_213913) do
  create_table "lines", force: :cascade do |t|
    t.string "code"
    t.string "line_id"
    t.string "description"
    t.string "description_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_lines_on_code", unique: true
  end

  create_table "routes", force: :cascade do |t|
    t.string "code"
    t.string "route_id"
    t.string "description"
    t.boolean "active", default: true
    t.string "description_en"
    t.integer "line_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_routes_on_code", unique: true
    t.index ["line_id"], name: "index_routes_on_line_id"
  end

  create_table "routes_stops", id: false, force: :cascade do |t|
    t.integer "route_id", null: false
    t.integer "stop_id", null: false
    t.integer "order"
    t.index ["route_id", "stop_id"], name: "index_routes_stops_on_route_id_and_stop_id"
    t.index ["stop_id", "route_id"], name: "index_routes_stops_on_stop_id_and_route_id"
  end

  create_table "stops", force: :cascade do |t|
    t.string "code"
    t.string "stop_id"
    t.string "description"
    t.string "description_en"
    t.string "street"
    t.string "street_en"
    t.string "heading"
    t.string "lat"
    t.string "lng"
    t.string "stop_type"
    t.boolean "amea"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_stops_on_code", unique: true
  end

  add_foreign_key "routes", "lines"
end
