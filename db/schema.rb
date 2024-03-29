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

ActiveRecord::Schema[7.0].define(version: 2019_04_13_210327) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "admins", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "provider"
    t.string "uid"
    t.string "full_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["uid"], name: "index_admins_on_uid", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "app_feature_completions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "app_id", null: false
    t.uuid "feature_gate_id", null: false
    t.integer "version", null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_app_feature_completions_on_app_id"
    t.index ["feature_gate_id", "app_id"], name: "index_app_feature_completions_on_feature_gate_id_and_app_id", unique: true
    t.index ["feature_gate_id"], name: "index_app_feature_completions_on_feature_gate_id"
  end

  create_table "app_migrations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "app_id"
    t.string "version", null: false
    t.index ["app_id", "version"], name: "index_app_migrations_on_app_id_and_version", unique: true
    t.index ["app_id"], name: "index_app_migrations_on_app_id"
  end

  create_table "app_remote_kills", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "app_id", null: false
    t.uuid "split_id", null: false
    t.string "reason", null: false
    t.string "override_to", null: false
    t.integer "first_bad_version", null: false, array: true
    t.integer "fixed_version", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_app_remote_kills_on_app_id"
    t.index ["split_id", "app_id", "reason"], name: "index_app_remote_kills_on_split_id_and_app_id_and_reason", unique: true
    t.index ["split_id"], name: "index_app_remote_kills_on_split_id"
  end

  create_table "apps", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "auth_secret", null: false
  end

  create_table "assignments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "split_id", null: false
    t.uuid "visitor_id", null: false
    t.string "variant", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "individually_overridden", default: false, null: false
    t.string "mixpanel_result"
    t.uuid "bulk_assignment_id"
    t.uuid "visitor_supersession_id"
    t.string "context"
    t.boolean "force", default: false, null: false
    t.index ["bulk_assignment_id"], name: "index_assignments_on_bulk_assignment_id"
    t.index ["split_id", "visitor_id"], name: "index_assignments_on_split_id_and_visitor_id", unique: true
    t.index ["split_id"], name: "index_assignments_on_split_id"
    t.index ["visitor_id"], name: "index_assignments_on_visitor_id"
    t.index ["visitor_supersession_id"], name: "index_assignments_on_visitor_supersession_id"
  end

  create_table "bulk_assignments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer "admin_id", null: false
    t.string "reason", null: false
    t.uuid "split_id", null: false
    t.string "variant", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "force", default: false, null: false
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "identifier_types", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "owner_app_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_identifier_types_on_name", unique: true
    t.index ["owner_app_id"], name: "index_identifier_types_on_owner_app_id"
  end

  create_table "identifiers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "visitor_id", null: false
    t.uuid "identifier_type_id", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier_type_id"], name: "index_identifiers_on_identifier_type_id"
    t.index ["value", "identifier_type_id"], name: "index_identifiers_on_value_and_identifier_type_id", unique: true
    t.index ["visitor_id"], name: "index_identifiers_on_visitor_id"
  end

  create_table "previous_assignments", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "variant", null: false
    t.uuid "assignment_id", null: false
    t.datetime "superseded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "bulk_assignment_id"
    t.boolean "individually_overridden", default: false, null: false
    t.string "context"
    t.uuid "visitor_supersession_id"
    t.boolean "force", default: false, null: false
    t.index ["assignment_id"], name: "index_previous_assignments_on_assignment_id"
    t.index ["superseded_at"], name: "index_previous_assignments_on_superseded_at"
    t.index ["visitor_supersession_id"], name: "index_previous_assignments_on_visitor_supersession_id"
  end

  create_table "previous_split_registries", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "split_id", null: false
    t.json "registry", null: false
    t.datetime "superseded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["split_id"], name: "index_previous_split_registries_on_split_id"
    t.index ["superseded_at"], name: "index_previous_split_registries_on_superseded_at"
  end

  create_table "splits", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.uuid "owner_app_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "finished_at"
    t.json "registry", null: false
    t.text "hypothesis"
    t.text "assignment_criteria"
    t.text "description"
    t.string "owner"
    t.string "location"
    t.integer "platform"
    t.boolean "feature_gate", default: false, null: false
    t.datetime "decided_at"
    t.index ["name"], name: "index_splits_on_name", unique: true
    t.index ["owner_app_id"], name: "index_splits_on_owner_app_id"
  end

  create_table "variant_details", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "split_id", null: false
    t.string "variant", null: false
    t.string "display_name", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "screenshot_file_name"
    t.string "screenshot_content_type"
    t.integer "screenshot_file_size"
    t.datetime "screenshot_updated_at"
    t.index ["split_id", "variant"], name: "index_variant_details_on_split_id_and_variant", unique: true
    t.index ["split_id"], name: "index_variant_details_on_split_id"
  end

  create_table "visitor_supersessions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid "superseded_visitor_id", null: false
    t.uuid "superseding_visitor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["superseded_visitor_id"], name: "index_visitor_supersessions_on_superseded_visitor_id"
    t.index ["superseding_visitor_id"], name: "index_visitor_supersessions_on_superseding_visitor_id"
  end

  create_table "visitors", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "app_feature_completions", "apps"
  add_foreign_key "app_feature_completions", "splits", column: "feature_gate_id"
  add_foreign_key "app_migrations", "apps"
  add_foreign_key "app_remote_kills", "apps"
  add_foreign_key "app_remote_kills", "splits"
  add_foreign_key "assignments", "bulk_assignments"
  add_foreign_key "assignments", "splits"
  add_foreign_key "assignments", "visitor_supersessions"
  add_foreign_key "assignments", "visitors"
  add_foreign_key "bulk_assignments", "admins"
  add_foreign_key "bulk_assignments", "splits"
  add_foreign_key "identifier_types", "apps", column: "owner_app_id"
  add_foreign_key "identifiers", "identifier_types"
  add_foreign_key "identifiers", "visitors"
  add_foreign_key "previous_assignments", "assignments"
  add_foreign_key "previous_assignments", "bulk_assignments"
  add_foreign_key "previous_assignments", "visitor_supersessions"
  add_foreign_key "previous_split_registries", "splits"
  add_foreign_key "splits", "apps", column: "owner_app_id"
  add_foreign_key "variant_details", "splits"
  add_foreign_key "visitor_supersessions", "visitors", column: "superseded_visitor_id"
  add_foreign_key "visitor_supersessions", "visitors", column: "superseding_visitor_id"
end
