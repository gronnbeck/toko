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

ActiveRecord::Schema[8.1].define(version: 2026_03_17_192543) do
  create_table "agents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "last_seen_at"
    t.string "name", null: false
    t.integer "organization_id"
    t.integer "status", default: 3, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_agents_on_organization_id"
    t.index ["token"], name: "index_agents_on_token", unique: true
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prompts", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "kind", default: 0, null: false
    t.integer "promptable_id", null: false
    t.string "promptable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["promptable_type", "promptable_id"], name: "index_prompts_on_promptable"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "claimed_by_id"
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["claimed_by_id"], name: "index_tasks_on_claimed_by_id"
  end

  add_foreign_key "agents", "organizations"
  add_foreign_key "tasks", "agents", column: "claimed_by_id"
end
