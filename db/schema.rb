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

ActiveRecord::Schema.define(version: 20150428033943) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "crossmaps", id: :serial, force: :cascade do |t|
    t.string "filename"
    t.string "input"
    t.string "output"
    t.string "token"
    t.string "col_sep"
    t.string "status", default: "init"
    t.integer "data_source_id"
    t.boolean "skip_original", default: false
    t.boolean "stop_trigger", default: false
    t.jsonb "alt_headers"
    t.jsonb "params"
    t.jsonb "input_sample"
    t.jsonb "stats"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
