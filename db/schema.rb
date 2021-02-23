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

ActiveRecord::Schema.define(version: 2021_02_26_215134) do

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
    t.string "title", limit: 200
    t.string "named_id", limit: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "abbrev", limit: 10
    t.string "revision", limit: 10
    t.index ["named_id"], name: "index_assessment_publications_on_named_id"
  end

  create_table "assessment_scores", force: :cascade do |t|
    t.integer "assessment_id", null: false
    t.integer "assessment_indicator_id", null: false
    t.integer "value", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country_alpha3", limit: 3
    t.integer "assessment_publication_id"
  end

  create_table "benchmark_indicator_actions", force: :cascade do |t|
    t.integer "benchmark_indicator_id"
    t.string "text", limit: 1000
    t.integer "level"
    t.integer "sequence"
    t.integer "action_types", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "disease_id"
    t.index ["benchmark_indicator_id"], name: "index_benchmark_indicator_actions_on_benchmark_indicator_id"
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

  create_table "countries", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "alpha2", limit: 2
    t.string "alpha3", limit: 3
    t.string "country_code", limit: 3
    t.string "region", limit: 50
    t.string "sub_region", limit: 50
    t.string "intermediate_region", limit: 50
    t.string "region_code", limit: 3
    t.string "sub_region_code", limit: 3
    t.string "intermediate_region_code", limit: 3
    t.index ["alpha2"], name: "index_countries_on_alpha2", unique: true
    t.index ["alpha3"], name: "index_countries_on_alpha3", unique: true
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "diseases", force: :cascade do |t|
    t.string "display"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plan_actions", force: :cascade do |t|
    t.integer "plan_id"
    t.integer "benchmark_indicator_action_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "benchmark_indicator_id"
    t.integer "benchmark_technical_area_id"
    t.index ["plan_id"], name: "index_plan_actions_on_plan_id"
  end

  create_table "plan_diseases", id: false, force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.bigint "disease_id", null: false
    t.index ["plan_id", "disease_id"], name: "index_plan_diseases_on_plan_id_and_disease_id", unique: true
  end

  create_table "plan_goals", force: :cascade do |t|
    t.integer "plan_id", null: false
    t.integer "assessment_indicator_id", null: false
    t.integer "benchmark_indicator_id", null: false
    t.integer "value", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "assessment_id"
    t.integer "term"
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
  add_foreign_key "assessment_scores", "assessment_indicators"
  add_foreign_key "assessment_scores", "assessments"
  add_foreign_key "assessment_technical_areas", "assessment_publications"
  add_foreign_key "assessments", "assessment_publications"
  add_foreign_key "assessments", "countries", column: "country_alpha3", primary_key: "alpha3"
  add_foreign_key "benchmark_indicator_actions", "benchmark_indicators"
  add_foreign_key "benchmark_indicator_actions", "diseases"
  add_foreign_key "benchmark_indicators", "benchmark_technical_areas"
  add_foreign_key "plan_actions", "benchmark_indicator_actions"
  add_foreign_key "plan_actions", "benchmark_indicators"
  add_foreign_key "plan_actions", "benchmark_technical_areas"
  add_foreign_key "plan_actions", "plans"
  add_foreign_key "plan_diseases", "diseases"
  add_foreign_key "plan_diseases", "plans"
  add_foreign_key "plan_goals", "assessment_indicators"
  add_foreign_key "plan_goals", "benchmark_indicators"
  add_foreign_key "plan_goals", "plans"
  add_foreign_key "plans", "assessments"
  add_foreign_key "plans", "users"
end
