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

ActiveRecord::Schema.define(version: 2020_11_27_152131) do

  create_table "stock_prices", id: false, force: :cascade do |t|
    t.string "code", null: false
    t.date "dt", null: false
    t.decimal "close"
    t.decimal "normalized"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code", "dt"], name: "index_stock_prices_on_code_and_dt", unique: true
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
    t.integer "open_day", default: 1, null: false
    t.integer "close_day"
    t.string "normalized_name", default: "", null: false
    t.index ["code", "m", "open_day"], name: "index_stock_quotations_on_code_and_m_and_open_day", unique: true
  end
end
