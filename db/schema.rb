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

ActiveRecord::Schema.define(version: 20160416174743) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calls", force: :cascade do |t|
    t.text     "description"
    t.integer  "est_duration_in_min"
    t.integer  "user_id"
    t.integer  "expert_id"
    t.integer  "user_rating"
    t.integer  "expert_rating"
    t.text     "user_review"
    t.text     "expert_review"
    t.datetime "offer_time_one"
    t.datetime "offer_time_two"
    t.datetime "offer_time_three"
    t.datetime "scheduled_at"
    t.datetime "user_accepted_at"
    t.datetime "expert_accepted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "cancelled_at"
    t.string   "cancellation_reason"
    t.integer  "cancelled_by"
    t.datetime "started_at"
    t.datetime "ended_at"
  end

  create_table "charges", force: :cascade do |t|
    t.integer  "amount"
    t.integer  "call_id"
    t.integer  "user_id"
    t.text     "notes"
    t.string   "stripe_py_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "educations", force: :cascade do |t|
    t.string   "name"
    t.integer  "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "admin"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.string   "name"
    t.boolean  "expert"
    t.text     "expertise"
    t.string   "current_work"
    t.integer  "rate_per_minute"
    t.text     "past_work"
    t.string   "languages"
    t.string   "location"
    t.boolean  "domestic"
    t.string   "title"
    t.string   "phone"
    t.string   "wechat"
    t.string   "stripe_cus_id"
    t.string   "auth_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
