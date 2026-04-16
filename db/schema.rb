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

ActiveRecord::Schema[7.2].define(version: 2026_04_16_000006) do
  create_table "attempts", force: :cascade do |t|
    t.string "prompt_id", null: false
    t.integer "challenge_id", null: false
    t.string "fixture_name", null: false
    t.text "candidate_result", null: false
    t.text "reference_result", null: false
    t.float "difference", default: 0.0, null: false
    t.string "status", default: "pending_interpretation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "algorithm_version", null: false
    t.string "reference_version", null: false
    t.index ["algorithm_version"], name: "index_attempts_on_algorithm_version"
    t.index ["challenge_id"], name: "index_attempts_on_challenge_id"
    t.index ["prompt_id", "fixture_name", "algorithm_version", "reference_version"], name: "index_attempts_on_prompt_fixture_algorithm_reference", unique: true
    t.index ["prompt_id"], name: "index_attempts_on_prompt_id"
    t.index ["reference_version"], name: "index_attempts_on_reference_version"
  end

  create_table "challenges", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "interpretations", force: :cascade do |t|
    t.integer "attempt_id", null: false
    t.string "classification", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attempt_id"], name: "index_interpretations_on_attempt_id"
  end

  create_table "prompts", force: :cascade do |t|
    t.string "prompt_id", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prompt_id"], name: "index_prompts_on_prompt_id", unique: true
  end

  add_foreign_key "attempts", "challenges"
  add_foreign_key "interpretations", "attempts"
end
