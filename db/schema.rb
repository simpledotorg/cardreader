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

ActiveRecord::Schema.define(version: 2018_09_28_115016) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "districts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "facilities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "district_id"
    t.uuid "simple_uuid"
    t.index ["district_id"], name: "index_facilities_on_district_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "treatment_number"
    t.date "registered_on"
    t.bigint "facility_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "alternate_id_number"
    t.string "name"
    t.string "gender"
    t.integer "age"
    t.string "house_number"
    t.string "street_name"
    t.string "area"
    t.string "village"
    t.string "district"
    t.string "pincode"
    t.string "phone"
    t.string "alternate_phone"
    t.boolean "already_on_treatment"
    t.boolean "prior_heart_attack"
    t.boolean "heard_attack_in_last_3_years"
    t.boolean "prior_stroke"
    t.boolean "chronic_kidney_disease"
    t.string "medication1_name"
    t.string "medication1_dose"
    t.string "medication2_name"
    t.string "medication2_dose"
    t.string "medication3_name"
    t.string "medication3_dose"
    t.string "medication4_name"
    t.string "medication4_dose"
    t.index ["facility_id"], name: "index_patients_on_facility_id"
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "patient_id"
    t.integer "systolic"
    t.integer "diastolic"
    t.date "measured_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "blood_sugar"
    t.string "amlodipine"
    t.string "telmisartan"
    t.string "enalpril"
    t.string "chlorthalidone"
    t.string "aspirin"
    t.string "statin"
    t.string "beta_blocker"
    t.boolean "referred_to_specialist"
    t.date "next_visit_on"
    t.string "losartan"
    t.string "medication1_name"
    t.string "medication1_dose"
    t.string "medication2_name"
    t.string "medication2_dose"
    t.string "medication3_name"
    t.string "medication3_dose"
    t.bigint "facilities_id"
    t.index ["facilities_id"], name: "index_visits_on_facilities_id"
    t.index ["patient_id"], name: "index_visits_on_patient_id"
  end

  add_foreign_key "patients", "facilities"
  add_foreign_key "visits", "patients"
end
