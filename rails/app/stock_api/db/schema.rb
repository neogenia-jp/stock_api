# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_24_064620) do

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.integer "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "company_name"
    t.string "department"
    t.string "contact_name"
    t.string "tel"
    t.string "line_user_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_user_id"], name: "index_customers_on_line_user_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "estimate_details", force: :cascade do |t|
    t.integer "estimate_id", null: false
    t.integer "num", null: false
    t.string "product_cd", null: false
    t.integer "quantity", null: false
    t.integer "regular_price"
    t.decimal "unit_weight", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["estimate_id"], name: "index_estimate_details_on_estimate_id"
  end

  create_table "estimates", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.datetime "requested_at", null: false
    t.decimal "total_weight", null: false
    t.integer "is_completed", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "access_key"
    t.index ["access_key"], name: "index_estimates_on_access_key", unique: true
    t.index ["customer_id"], name: "index_estimates_on_customer_id"
  end

  create_table "massage_templates", force: :cascade do |t|
    t.string "type_name", limit: 50, null: false
    t.string "display_title", limit: 100, null: false
    t.string "subject", limit: 250
    t.text "body", limit: 65535
    t.integer "hidden"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["type_name"], name: "index_mail_templates_on_type_name", unique: true
  end

  create_table "notification_histories", force: :cascade do |t|
    t.integer "notification_type_id", null: false
    t.string "notified_to", null: false
    t.datetime "executed_at", null: false
    t.integer "is_successful", null: false
    t.integer "message_id"
    t.string "title"
    t.string "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["message_id"], name: "index_notification_histories_on_message_id"
  end

  create_table "products", primary_key: "product_cd", id: :string, force: :cascade do |t|
    t.string "product_name", null: false
    t.string "spec"
    t.integer "regular_price"
    t.decimal "unit_weight"
    t.string "disp_spec"
    t.string "disp_order"
    t.integer "category_id"
    t.datetime "deleted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_products_on_category_id"
  end

  create_table "stock_quotations", id: false, force: :cascade do |t|
    t.string "code"
    t.date "m"
    t.string "name"
    t.decimal "open"
    t.decimal "high"
    t.decimal "low"
    t.decimal "close"
    t.decimal "avg_closing"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code", "m"], name: "index_stock_quotations_on_code_and_m", unique: true
  end

  add_foreign_key "estimate_details", "estimates", on_delete: :cascade
end
