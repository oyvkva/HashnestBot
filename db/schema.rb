# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151221195957) do

  create_table "btcusds", force: :cascade do |t|
    t.float    "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "datasets", force: :cascade do |t|
    t.integer  "difficulty",    limit: 8
    t.float    "btc_price"
    t.float    "s3_btc"
    t.float    "s4_btc"
    t.float    "s5_btc"
    t.float    "s7_btc"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.float    "s3_buyVolume"
    t.float    "s3_sellVolume"
    t.float    "s4_buyVolume"
    t.float    "s4_sellVolume"
    t.float    "s5_buyVolume"
    t.float    "s5_sellVolume"
    t.float    "s7_buyVolume"
    t.float    "s7_sellVolume"
  end

  create_table "orders", force: :cascade do |t|
    t.float    "price"
    t.integer  "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "ordertype"
    t.string   "market"
  end

  create_table "prices", force: :cascade do |t|
    t.string   "market"
    t.float    "btc_price"
    t.float    "usd_price"
    t.float    "return"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
