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

ActiveRecord::Schema.define(version: 20140429042540) do

  create_table "addresses", force: true do |t|
    t.string   "full_address"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.boolean  "default"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["user_id"], name: "index_addresses_on_user_id"

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"

  create_table "identities", force: true do |t|
    t.string   "uid"
    t.string   "provider"
    t.string   "token"
    t.string   "secret"
    t.datetime "expires_at"
    t.string   "email"
    t.string   "image"
    t.string   "nickname"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "user_id"
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id"

  create_table "recommendations", force: true do |t|
    t.boolean  "like"
    t.string   "description"
    t.integer  "user_id"
    t.integer  "restaurant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pictures_file_name"
    t.string   "pictures_content_type"
    t.integer  "pictures_file_size"
    t.datetime "pictures_updated_at"
  end

  add_index "recommendations", ["restaurant_id"], name: "index_recommendations_on_restaurant_id"
  add_index "recommendations", ["user_id"], name: "index_recommendations_on_user_id"

  create_table "restaurants", force: true do |t|
    t.string   "name"
    t.string   "location"
    t.string   "yelp_id"
    t.string   "foursquare_id"
    t.string   "google_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "image"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
