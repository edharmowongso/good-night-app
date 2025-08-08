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

ActiveRecord::Schema[7.1].define(version: 4) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "follows", force: :cascade do |t|
    t.bigint "follower_id", null: false, comment: "User who is following"
    t.bigint "followed_id", null: false, comment: "User being followed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_follows_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_follows_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_follows_on_follower_id"
  end

  create_table "sleep_records", force: :cascade do |t|
    t.bigint "user_id", null: false, comment: "User who owns this sleep record"
    t.datetime "bedtime", null: false, comment: "When user went to bed"
    t.datetime "wake_time", comment: "When user woke up (null if still sleeping)"
    t.integer "duration_minutes", comment: "Calculated sleep duration in minutes"
    t.integer "score", comment: "Sleep quality rating from 1-5 (1=terrible, 5=excellent)"
    t.text "notes", comment: "Personal sleep notes and reflections"
    t.integer "status", default: 0, null: false, comment: "Sleep record status: 0=incomplete, 1=completed, 2=cancelled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "sleep_date", comment: "Date of the sleep session (for efficient date filtering)"
    t.index ["duration_minutes"], name: "index_sleep_records_on_duration_minutes"
    t.index ["status"], name: "index_sleep_records_on_status"
    t.index ["user_id", "sleep_date"], name: "idx_sleep_records_user_date"
    t.index ["user_id", "status"], name: "idx_sleep_records_user_status"
    t.index ["user_id"], name: "index_sleep_records_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false, comment: "User display name"
    t.string "username", null: false, comment: "Unique username"
    t.integer "user_status", default: 0, null: false, comment: "User account status: 0=active; 1=inactive"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_status"], name: "index_users_on_user_status"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "follows", "users", column: "followed_id"
  add_foreign_key "follows", "users", column: "follower_id"
  add_foreign_key "sleep_records", "users"
end
