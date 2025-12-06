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

ActiveRecord::Schema[8.1].define(version: 2025_12_06_011219) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "budget"
    t.datetime "created_at", null: false
    t.text "custom_message"
    t.text "description"
    t.date "event_date"
    t.datetime "launched_at"
    t.string "location"
    t.string "name"
    t.string "organizer_email"
    t.string "organizer_name"
    t.boolean "organizer_participates", default: true, null: false
    t.boolean "require_address", default: false, null: false
    t.boolean "require_rsvp", default: false, null: false
    t.boolean "require_wishlist", default: true, null: false
    t.string "slug"
    t.string "status", default: "draft", null: false
    t.string "theme", default: "christmas"
    t.string "theme_primary_color"
    t.string "theme_secondary_color"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_events_on_slug", unique: true
    t.index ["status"], name: "index_events_on_status"
  end

  create_table "login_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.bigint "participant_id", null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.index ["participant_id"], name: "index_login_tokens_on_participant_id"
    t.index ["token"], name: "index_login_tokens_on_token", unique: true
  end

  create_table "participants", force: :cascade do |t|
    t.integer "assigned_to_id"
    t.datetime "created_at", null: false
    t.string "email"
    t.bigint "event_id", null: false
    t.datetime "invitation_sent_at"
    t.boolean "is_organizer", default: false
    t.datetime "last_sign_in_at"
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["assigned_to_id"], name: "index_participants_on_assigned_to_id"
    t.index ["event_id", "email"], name: "index_participants_on_event_id_and_email", unique: true
    t.index ["event_id"], name: "index_participants_on_event_id"
    t.index ["user_id"], name: "index_participants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "participant_id", null: false
    t.string "price"
    t.integer "priority"
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["participant_id"], name: "index_wishlist_items_on_participant_id"
  end

  add_foreign_key "login_tokens", "participants"
  add_foreign_key "participants", "events"
  add_foreign_key "participants", "users"
  add_foreign_key "wishlist_items", "participants"
end
