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

ActiveRecord::Schema.define(version: 2019_11_28_030150) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assessment_indicators", force: :cascade do |t|
    t.integer "assessment_technical_area_id"
    t.string "named_id", limit: 20
    t.integer "sequence"
    t.string "text", limit: 500
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_technical_area_id"], name: "index_assessment_indicators_on_assessment_technical_area_id"
  end

  create_table "assessment_indicators_benchmark_indicators", id: false, force: :cascade do |t|
    t.integer "assessment_indicator_id"
    t.integer "benchmark_indicator_id"
    t.index ["assessment_indicator_id", "benchmark_indicator_id"], name: "BI_to_EI_each_pair_must_be_unique", unique: true
    t.index ["assessment_indicator_id"], name: "BI_to_EI_assessment_indicator_id"
    t.index ["benchmark_indicator_id"], name: "BI_to_EI_benchmark_indicator_id"
  end

  create_table "assessment_publications", force: :cascade do |t|
    t.string "name", limit: 20
    t.string "title", limit: 200
    t.string "named_id", limit: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["named_id"], name: "index_assessment_publications_on_named_id"
  end

  create_table "assessment_technical_areas", force: :cascade do |t|
    t.integer "assessment_publication_id"
    t.string "named_id", limit: 20
    t.integer "sequence"
    t.string "text", limit: 200
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_publication_id"], name: "index_assessment_technical_areas_on_assessment_publication_id"
  end

  create_table "assessments", force: :cascade do |t|
    t.string "country"
    t.string "assessment_type"
    t.jsonb "scores"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country", "assessment_type"], name: "index_assessments_on_country_and_assessment_type", unique: true
  end

  create_table "benchmark_indicator_activities", force: :cascade do |t|
    t.integer "benchmark_indicator_id"
    t.string "text", limit: 1000
    t.integer "level"
    t.integer "sequence"
    t.integer "activity_types", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["benchmark_indicator_id"], name: "index_benchmark_indicator_activities_on_benchmark_indicator_id"
  end

  create_table "benchmark_indicators", force: :cascade do |t|
    t.integer "benchmark_technical_area_id"
    t.integer "sequence"
    t.string "display_abbreviation", limit: 10
    t.string "text", limit: 500
    t.string "objective", limit: 500
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["benchmark_technical_area_id"], name: "index_benchmark_indicators_on_benchmark_technical_area_id"
  end

  create_table "benchmark_technical_areas", force: :cascade do |t|
    t.string "text", limit: 200
    t.integer "sequence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plan_activities", force: :cascade do |t|
    t.integer "plan_id"
    t.integer "benchmark_indicator_activity_id"
    t.integer "benchmark_indicator_id"
    t.integer "sequence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id", "benchmark_indicator_id"], name: "index_plan_activities_on_plan_id_and_benchmark_indicator_id"
    t.index ["plan_id"], name: "index_plan_activities_on_plan_id"
  end

  create_table "plan_benchmark_indicators", force: :cascade do |t|
    t.integer "plan_id"
    t.integer "assessment_indicator_id"
    t.integer "benchmark_indicator_id"
    t.integer "score"
    t.integer "goal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id", "assessment_indicator_id"], name: "plan_BIs_plan_id_and_assessment_indicator_id"
    t.index ["plan_id", "benchmark_indicator_id"], name: "plan_BIs_plan_id_and_benchmark_indicator_id"
    t.index ["plan_id"], name: "index_plan_benchmark_indicators_on_plan_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.string "country"
    t.string "assessment_type"
    t.jsonb "activity_map"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.jsonb "goals"
    t.jsonb "scores"
    t.index ["user_id"], name: "index_plans_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "role", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "assessment_indicators", "assessment_technical_areas"
  add_foreign_key "assessment_indicators_benchmark_indicators", "assessment_indicators"
  add_foreign_key "assessment_indicators_benchmark_indicators", "benchmark_indicators"
  add_foreign_key "assessment_technical_areas", "assessment_publications"
  add_foreign_key "benchmark_indicator_activities", "benchmark_indicators"
  add_foreign_key "benchmark_indicators", "benchmark_technical_areas"
  add_foreign_key "plan_activities", "benchmark_indicator_activities"
  add_foreign_key "plan_activities", "benchmark_indicators"
  add_foreign_key "plan_activities", "plans"
  add_foreign_key "plan_benchmark_indicators", "assessment_indicators"
  add_foreign_key "plan_benchmark_indicators", "benchmark_indicators"
  add_foreign_key "plan_benchmark_indicators", "plans"
  add_foreign_key "plans", "users"
end
