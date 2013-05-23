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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130523034509) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "perma"
    t.integer  "industry_id"
    t.string   "crunch_url"
    t.string   "home_url"
    t.date     "founded_date"
    t.date     "dead_date"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "financials", :force => true do |t|
    t.string   "name"
    t.string   "perma"
    t.string   "crunch_url"
    t.string   "home_url"
    t.date     "founded_date"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "fundings", :force => true do |t|
    t.integer  "company_id"
    t.string   "company_perma"
    t.string   "funding_code"
    t.float    "funding_amount"
    t.string   "funding_currency"
    t.date     "funding_date"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "individuals", :force => true do |t|
    t.string   "name"
    t.string   "perma"
    t.string   "crunch_url"
    t.string   "home_url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "industries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "investments", :force => true do |t|
    t.integer  "funding_id"
    t.string   "investor_perma"
    t.integer  "investor_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

end
