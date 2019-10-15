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

ActiveRecord::Schema.define(version: 2019_10_15_133907) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.citext "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "parent_id"
    t.index ["name"], name: "index_categories_on_name"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "category_things", force: :cascade do |t|
    t.bigint "category_id"
    t.bigint "thing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "thing_id"], name: "index_category_things_on_category_id_and_thing_id", unique: true
    t.index ["category_id"], name: "index_category_things_on_category_id"
    t.index ["thing_id"], name: "index_category_things_on_thing_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "model_version_images", force: :cascade do |t|
    t.citext "name"
    t.string "filepath"
    t.integer "index"
    t.jsonb "metadata", default: {}
    t.jsonb "image_data"
    t.bigint "model_version_id"
    t.bigint "thing_id"
    t.bigint "thing_file_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["model_version_id", "index"], name: "index_model_version_images_on_model_version_id_and_index", unique: true
    t.index ["model_version_id", "thing_file_id"], name: "index_model_version_images_on_model_version_id_and_thing_file_i", unique: true
    t.index ["thing_id"], name: "index_model_version_images_on_thing_id"
  end

  create_table "model_versions", force: :cascade do |t|
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false
    t.boolean "active", default: true
  end

  create_table "tag_things", force: :cascade do |t|
    t.bigint "tag_id"
    t.bigint "thing_id"
    t.boolean "manual", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id", "thing_id"], name: "index_tag_things_on_tag_id_and_thing_id", unique: true
    t.index ["tag_id"], name: "index_tag_things_on_tag_id"
    t.index ["thing_id"], name: "index_tag_things_on_thing_id"
  end

  create_table "tags", force: :cascade do |t|
    t.citext "name"
    t.boolean "manual", default: false
    t.integer "thing_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "thing_files", force: :cascade do |t|
    t.citext "name"
    t.integer "thingiverse_id"
    t.integer "download_count"
    t.bigint "thing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.index ["thing_id"], name: "index_thing_files_on_thing_id"
    t.index ["thingiverse_id"], name: "index_thing_files_on_thingiverse_id", unique: true
  end

  create_table "things", force: :cascade do |t|
    t.citext "name"
    t.integer "thingiverse_id"
    t.string "image_url"
    t.datetime "added_on"
    t.datetime "updated_on"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "like_count", default: 0
    t.integer "download_count", default: 0
    t.bigint "job_id"
    t.boolean "deleted", default: false
    t.datetime "category_updated"
    t.datetime "tag_updated"
    t.datetime "file_updated"
    t.index ["category_updated"], name: "index_things_on_category_updated"
    t.index ["file_updated"], name: "index_things_on_file_updated"
    t.index ["job_id"], name: "index_things_on_job_id"
    t.index ["tag_updated"], name: "index_things_on_tag_updated"
    t.index ["thingiverse_id"], name: "index_things_on_thingiverse_id", unique: true
    t.index ["user_id"], name: "index_things_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "thingiverse_id"
    t.citext "name"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["thingiverse_id"], name: "index_users_on_thingiverse_id", unique: true
  end

end
