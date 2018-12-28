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

ActiveRecord::Schema.define(version: 2018_12_28_130259) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

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
    t.integer "author_id"
    t.index ["district_id"], name: "index_facilities_on_district_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "treatment_number"
    t.date "registered_on"
    t.bigint "facility_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean "heart_attack_in_last_3_years"
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
    t.uuid "patient_uuid", default: -> { "uuid_generate_v4()" }
    t.uuid "address_uuid", default: -> { "uuid_generate_v4()" }
    t.uuid "phone_uuid", default: -> { "uuid_generate_v4()" }
    t.uuid "alternate_phone_uuid", default: -> { "uuid_generate_v4()" }
    t.uuid "medical_history_uuid", default: -> { "uuid_generate_v4()" }
    t.boolean "diagnosed_with_hypertension"
    t.integer "author_id"
    t.index ["facility_id"], name: "index_patients_on_facility_id"
  end

  create_table "sync_logs", force: :cascade do |t|
    t.string "simple_model"
    t.uuid "simple_id"
    t.datetime "synced_at", null: false
    t.json "sync_errors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["simple_model", "simple_id"], name: "index_sync_logs_on_simple_model_and_simple_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
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
    t.uuid "blood_pressure_uuid", default: -> { "uuid_generate_v4()" }
    t.uuid "appointment_uuid", default: -> { "uuid_generate_v4()" }
    t.integer "author_id"
    t.index ["patient_id"], name: "index_visits_on_patient_id"
  end

  add_foreign_key "facilities", "users", column: "author_id"
  add_foreign_key "patients", "facilities"
  add_foreign_key "patients", "users", column: "author_id"
  add_foreign_key "visits", "patients"
  add_foreign_key "visits", "users", column: "author_id"
end
