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

ActiveRecord::Schema[7.1].define(version: 2026_04_12_115833) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.bigint "lead_id", null: false
    t.bigint "user_id", null: false
    t.string "activity_type"
    t.text "description"
    t.datetime "occurred_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_activities_on_lead_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "construction_sites", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name"
    t.string "site_manager"
    t.string "status"
    t.date "start_date"
    t.date "expected_completion"
    t.integer "overall_progress"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_construction_sites_on_project_id"
  end

  create_table "construction_tasks", force: :cascade do |t|
    t.bigint "milestone_id", null: false
    t.bigint "user_id", null: false
    t.string "title"
    t.text "description"
    t.string "status"
    t.string "priority"
    t.date "due_date"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["milestone_id"], name: "index_construction_tasks_on_milestone_id"
    t.index ["user_id"], name: "index_construction_tasks_on_user_id"
  end

  create_table "leads", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "property_id", null: false
    t.bigint "user_id", null: false
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "source"
    t.decimal "budget"
    t.string "stage"
    t.text "notes"
    t.datetime "follow_up_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_leads_on_project_id"
    t.index ["property_id"], name: "index_leads_on_property_id"
    t.index ["user_id"], name: "index_leads_on_user_id"
  end

  create_table "materials", force: :cascade do |t|
    t.bigint "construction_site_id", null: false
    t.string "name"
    t.string "unit"
    t.float "quantity_ordered"
    t.float "quantity_received"
    t.float "quantity_used"
    t.decimal "unit_price"
    t.string "vendor"
    t.date "last_updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["construction_site_id"], name: "index_materials_on_construction_site_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.bigint "construction_site_id", null: false
    t.string "title"
    t.text "description"
    t.date "planned_date"
    t.date "actual_date"
    t.string "status"
    t.integer "completion_pct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["construction_site_id"], name: "index_milestones_on_construction_site_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.text "description"
    t.string "status"
    t.integer "total_units"
    t.date "start_date"
    t.date "end_date"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "title"
    t.string "unit_number"
    t.integer "floor"
    t.string "property_type"
    t.decimal "price"
    t.float "area"
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.string "facing"
    t.string "status"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_properties_on_project_id"
  end

  create_table "site_documents", force: :cascade do |t|
    t.bigint "construction_site_id", null: false
    t.bigint "milestone_id", null: false
    t.string "title"
    t.string "document_type"
    t.text "description"
    t.string "uploaded_by_type", null: false
    t.bigint "uploaded_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["construction_site_id"], name: "index_site_documents_on_construction_site_id"
    t.index ["milestone_id"], name: "index_site_documents_on_milestone_id"
    t.index ["uploaded_by_type", "uploaded_by_id"], name: "index_site_documents_on_uploaded_by"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workers", force: :cascade do |t|
    t.bigint "construction_site_id", null: false
    t.string "name"
    t.string "role"
    t.string "phone"
    t.decimal "daily_wage"
    t.string "contractor_name"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["construction_site_id"], name: "index_workers_on_construction_site_id"
  end

  add_foreign_key "activities", "leads"
  add_foreign_key "activities", "users"
  add_foreign_key "construction_sites", "projects"
  add_foreign_key "construction_tasks", "milestones"
  add_foreign_key "construction_tasks", "users"
  add_foreign_key "leads", "projects"
  add_foreign_key "leads", "properties"
  add_foreign_key "leads", "users"
  add_foreign_key "materials", "construction_sites"
  add_foreign_key "milestones", "construction_sites"
  add_foreign_key "projects", "users"
  add_foreign_key "properties", "projects"
  add_foreign_key "site_documents", "construction_sites"
  add_foreign_key "site_documents", "milestones"
  add_foreign_key "workers", "construction_sites"
end
