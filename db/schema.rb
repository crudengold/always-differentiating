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

ActiveRecord::Schema[7.1].define(version: 2024_04_21_113627) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "feedbacks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "feedback"
  end

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
    t.integer "deductions", default: 0
    t.integer "total_after_deductions", default: 0
  end

  create_table "penalties", force: :cascade do |t|
    t.integer "points_deducted"
    t.bigint "fplteam_id", null: false
    t.bigint "player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending"
    t.integer "gameweek"
    t.index ["fplteam_id"], name: "index_penalties_on_fplteam_id"
    t.index ["player_id"], name: "index_penalties_on_player_id"
  end

  create_table "picks", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "fplteam_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gameweek"
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
    t.text "past_ownership_stats"
  end

  create_table "selected_by_stats", force: :cascade do |t|
    t.integer "gameweek"
    t.float "selected_by"
    t.bigint "player_id", null: false
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "penalties", "fplteams"
  add_foreign_key "penalties", "players"
  add_foreign_key "picks", "fplteams"
  add_foreign_key "picks", "players"
  add_foreign_key "selected_by_stats", "players"
end
