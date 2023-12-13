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

ActiveRecord::Schema[7.1].define(version: 2023_12_13_220252) do
  create_table "fplteams", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "event_total"
    t.string "player_name"
    t.integer "rank"
    t.integer "last_rank"
    t.integer "rank_sort"
    t.integer "total"
    t.integer "entry"
    t.string "entry_name"
    t.string "discord_name"
  end

  create_table "penalties", force: :cascade do |t|
    t.integer "points_deducted"
    t.integer "fplteam_id", null: false
    t.integer "player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending"
    t.index ["fplteam_id"], name: "index_penalties_on_fplteam_id"
    t.index ["player_id"], name: "index_penalties_on_player_id"
  end

  create_table "picks", force: :cascade do |t|
    t.integer "player_id", null: false
    t.integer "fplteam_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fplteam_id"], name: "index_picks_on_fplteam_id"
    t.index ["player_id"], name: "index_picks_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "code"
    t.integer "element_type"
    t.integer "event_points"
    t.string "first_name"
    t.integer "fpl_id"
    t.string "photo"
    t.string "second_name"
    t.integer "team"
    t.integer "total_points"
    t.string "web_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shirt"
  end

  create_table "selected_by_stats", force: :cascade do |t|
    t.integer "gameweek"
    t.float "selected_by"
    t.integer "player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_selected_by_stats_on_player_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "penalties", "fplteams"
  add_foreign_key "penalties", "players"
  add_foreign_key "picks", "fplteams"
  add_foreign_key "picks", "players"
  add_foreign_key "selected_by_stats", "players"
end
