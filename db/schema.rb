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

ActiveRecord::Schema[8.0].define(version: 2026_01_11_020047) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "families", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "family_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "family_id", null: false
    t.boolean "is_admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_id"], name: "index_family_memberships_on_family_id"
    t.index ["user_id", "family_id"], name: "index_family_memberships_on_user_id_and_family_id", unique: true
    t.index ["user_id"], name: "index_family_memberships_on_user_id"
  end

  create_table "season_goals", force: :cascade do |t|
    t.bigint "season_id", null: false
    t.integer "goal_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id"], name: "index_season_goals_on_season_id", unique: true
  end

  create_table "seasons", force: :cascade do |t|
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year"], name: "index_seasons_on_year", unique: true
  end

  create_table "tree_entries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "family_id", null: false
    t.bigint "season_id", null: false
    t.date "entry_date", null: false
    t.integer "tree_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_date"], name: "index_tree_entries_on_entry_date"
    t.index ["family_id", "season_id"], name: "index_tree_entries_on_family_id_and_season_id"
    t.index ["family_id"], name: "index_tree_entries_on_family_id"
    t.index ["season_id"], name: "index_tree_entries_on_season_id"
    t.index ["user_id"], name: "index_tree_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "family_memberships", "families"
  add_foreign_key "family_memberships", "users"
  add_foreign_key "season_goals", "seasons"
  add_foreign_key "tree_entries", "families"
  add_foreign_key "tree_entries", "seasons"
  add_foreign_key "tree_entries", "users"
end
