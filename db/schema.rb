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

ActiveRecord::Schema[8.1].define(version: 2026_03_07_134357) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "deck_songs", force: :cascade do |t|
    t.jsonb "arrangement"
    t.datetime "created_at", null: false
    t.bigint "deck_id", null: false
    t.string "key"
    t.integer "position"
    t.bigint "song_id", null: false
    t.datetime "updated_at", null: false
    t.index ["deck_id"], name: "index_deck_songs_on_deck_id"
    t.index ["song_id"], name: "index_deck_songs_on_song_id"
  end

  create_table "decks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.text "notes"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_decks_on_user_id"
  end

  create_table "lyrics", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.text "pinyin"
    t.integer "position"
    t.string "section_type"
    t.bigint "song_id", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_lyrics_on_song_id"
  end

  create_table "slides", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "deck_song_id", null: false
    t.bigint "lyric_id"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["deck_song_id"], name: "index_slides_on_deck_song_id"
    t.index ["lyric_id"], name: "index_slides_on_lyric_id"
  end

  create_table "songs", force: :cascade do |t|
    t.string "artist"
    t.datetime "created_at", null: false
    t.string "default_key"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "deck_songs", "decks"
  add_foreign_key "deck_songs", "songs"
  add_foreign_key "decks", "users"
  add_foreign_key "lyrics", "songs"
  add_foreign_key "slides", "deck_songs"
  add_foreign_key "slides", "lyrics", on_delete: :nullify
end
