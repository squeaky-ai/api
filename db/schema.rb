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

ActiveRecord::Schema[7.0].define(version: 2022_09_29_160121) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "billing", force: :cascade do |t|
    t.string "customer_id"
    t.bigint "user_id"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "new", null: false
    t.string "card_type"
    t.string "country"
    t.string "expiry"
    t.string "card_number"
    t.string "billing_name"
    t.string "billing_email"
    t.jsonb "billing_address"
    t.jsonb "tax_ids", default: [], null: false
    t.index ["site_id"], name: "index_billing_on_site_id"
    t.index ["user_id"], name: "index_billing_on_user_id"
  end

  create_table "blog", force: :cascade do |t|
    t.string "title", null: false
    t.string "tags", default: [], array: true
    t.string "author", null: false
    t.string "category", null: false
    t.boolean "draft", default: true, null: false
    t.string "meta_image", null: false
    t.string "meta_description", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "body", null: false
    t.string "scripts", default: [], null: false, array: true
  end

  create_table "clicks", force: :cascade do |t|
    t.string "selector", null: false
    t.integer "coordinates_x", null: false
    t.integer "coordinates_y", null: false
    t.string "page_url", null: false
    t.bigint "clicked_at", null: false
    t.integer "viewport_x", null: false
    t.integer "viewport_y", null: false
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "text"
    t.bigint "recording_id"
    t.integer "relative_to_element_x"
    t.integer "relative_to_element_y"
    t.index ["site_id"], name: "index_clicks_on_site_id"
  end

  create_table "communications", force: :cascade do |t|
    t.boolean "onboarding_email", null: false
    t.boolean "weekly_review_email", null: false
    t.boolean "monthly_review_email", null: false
    t.boolean "product_updates_email", null: false
    t.boolean "marketing_and_special_offers_email", null: false
    t.boolean "knowledge_sharing_email", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "feedback_email", default: true, null: false
    t.index ["user_id"], name: "index_communications_on_user_id"
  end

  create_table "consents", force: :cascade do |t|
    t.string "name"
    t.string "privacy_policy_url"
    t.string "layout"
    t.string "consent_method"
    t.string "languages", default: [], null: false, array: true
    t.string "languages_default"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_consents_on_site_id"
  end

  create_table "event_captures", force: :cascade do |t|
    t.string "name", null: false
    t.integer "event_type", null: false
    t.integer "count", default: 0, null: false
    t.json "rules", default: [], null: false
    t.datetime "last_counted_at"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "site_id"], name: "index_event_captures_on_name_and_site_id", unique: true
    t.index ["site_id"], name: "index_event_captures_on_site_id"
  end

  create_table "event_captures_groups", id: false, force: :cascade do |t|
    t.bigint "event_capture_id", null: false
    t.bigint "event_group_id", null: false
  end

  create_table "event_groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "site_id"
    t.index ["site_id"], name: "index_event_groups_on_site_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "event_type", null: false
    t.jsonb "data", null: false
    t.bigint "timestamp", null: false
    t.bigint "recording_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "site_id"
    t.index ["recording_id", "timestamp"], name: "index_events_on_recording_id_and_timestamp"
    t.index ["recording_id"], name: "index_events_on_recording_id"
    t.index ["site_id"], name: "index_events_on_site_id"
  end

  create_table "feedback", force: :cascade do |t|
    t.boolean "nps_enabled", default: false, null: false
    t.string "nps_accent_color"
    t.string "nps_schedule"
    t.string "nps_phrase"
    t.boolean "nps_follow_up_enabled"
    t.boolean "nps_contact_consent_enabled"
    t.string "nps_layout"
    t.boolean "sentiment_enabled", default: false, null: false
    t.string "sentiment_accent_color"
    t.string "sentiment_excluded_pages", default: [], null: false, array: true
    t.string "sentiment_layout"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sentiment_devices", default: [], null: false, array: true
    t.string "nps_excluded_pages", default: [], null: false, array: true
    t.string "nps_languages", default: [], null: false, array: true
    t.string "nps_languages_default"
    t.boolean "nps_hide_logo", default: false, null: false
    t.boolean "sentiment_hide_logo", default: false, null: false
    t.string "sentiment_schedule"
    t.index ["site_id"], name: "index_feedback_on_site_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "body"
    t.integer "timestamp"
    t.bigint "user_id"
    t.bigint "recording_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recording_id"], name: "index_notes_on_recording_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "nps", force: :cascade do |t|
    t.integer "score", null: false
    t.string "comment"
    t.boolean "contact", default: false, null: false
    t.bigint "recording_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.index ["recording_id"], name: "index_nps_on_recording_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "url", null: false
    t.bigint "entered_at", null: false
    t.bigint "exited_at", null: false
    t.bigint "recording_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "exited_on", default: false, null: false
    t.boolean "bounced_on", default: false, null: false
    t.bigint "site_id"
    t.index ["exited_at"], name: "index_pages_on_exited_at"
    t.index ["recording_id"], name: "index_pages_on_recording_id"
    t.index ["site_id"], name: "index_pages_on_site_id"
  end

  create_table "plans", force: :cascade do |t|
    t.integer "tier", null: false
    t.integer "max_monthly_recordings"
    t.integer "data_storage_months"
    t.integer "response_time_hours"
    t.string "support", default: [], null: false, array: true
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sso_enabled", default: false, null: false
    t.boolean "audit_trail_enabled", default: false, null: false
    t.boolean "private_instance_enabled", default: false, null: false
    t.string "notes"
    t.index ["site_id"], name: "index_plans_on_site_id"
  end

  create_table "recordings", force: :cascade do |t|
    t.string "session_id", null: false
    t.boolean "viewed", default: false
    t.boolean "bookmarked", default: false
    t.string "locale", null: false
    t.string "useragent", null: false
    t.integer "viewport_x", null: false
    t.integer "viewport_y", null: false
    t.bigint "connected_at", null: false
    t.bigint "disconnected_at", null: false
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "visitor_id"
    t.string "referrer"
    t.integer "device_x", default: -1, null: false
    t.integer "device_y", default: -1, null: false
    t.integer "pages_count"
    t.string "browser"
    t.string "device_type"
    t.integer "status"
    t.string "timezone"
    t.string "country_code"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_term"
    t.bigint "activity_duration"
    t.string "inactivity", default: [], null: false, array: true
    t.index ["disconnected_at"], name: "index_recordings_on_disconnected_at"
    t.index ["session_id"], name: "index_recordings_on_session_id", unique: true
    t.index ["site_id"], name: "index_recordings_on_site_id"
    t.index ["visitor_id"], name: "index_recordings_on_visitor_id"
  end

  create_table "recordings_tags", id: false, force: :cascade do |t|
    t.bigint "recording_id", null: false
    t.bigint "tag_id", null: false
  end

  create_table "sentiments", force: :cascade do |t|
    t.integer "score", null: false
    t.string "comment"
    t.bigint "recording_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recording_id"], name: "index_sentiments_on_recording_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string "name", null: false
    t.string "url", null: false
    t.string "uuid", null: false
    t.datetime "verified_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "ip_blacklist", default: [], null: false
    t.jsonb "domain_blacklist", default: [], null: false
    t.boolean "magic_erasure_enabled", default: false, null: false
    t.string "css_selector_blacklist", default: [], null: false, array: true
    t.boolean "anonymise_form_inputs", default: true, null: false
    t.boolean "superuser_access_enabled", default: false
    t.string "routes", default: [], null: false, array: true
    t.boolean "ingest_enabled", default: true, null: false
    t.boolean "consent_enabled", default: false, null: false
    t.index ["url"], name: "index_sites_on_url", unique: true
    t.index ["uuid"], name: "index_sites_on_uuid", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "site_id"
    t.index ["site_id"], name: "index_tags_on_site_id"
  end

  create_table "teams", force: :cascade do |t|
    t.integer "status"
    t.integer "role"
    t.bigint "user_id"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_teams_on_site_id"
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "amount", null: false
    t.string "currency", null: false
    t.string "invoice_web_url", null: false
    t.string "invoice_pdf_url", null: false
    t.string "interval", null: false
    t.string "pricing_id", null: false
    t.bigint "period_from", null: false
    t.bigint "period_to", null: false
    t.bigint "billing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "discount_name"
    t.float "discount_percentage"
    t.string "discount_id"
    t.integer "discount_amount"
    t.index ["billing_id"], name: "index_transactions_on_billing_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.string "invitation_token"
    t.datetime "invitation_created_at", precision: nil
    t.datetime "invitation_sent_at", precision: nil
    t.datetime "invitation_accepted_at", precision: nil
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "superuser", default: false
    t.datetime "last_activity_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "visitors", force: :cascade do |t|
    t.string "visitor_id", null: false
    t.boolean "starred", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "external_attributes", default: {}, null: false
    t.integer "recordings_count"
    t.boolean "new", default: true
    t.bigint "site_id"
    t.index ["site_id"], name: "index_visitors_on_site_id"
    t.index ["visitor_id"], name: "index_visitors_on_visitor_id", unique: true
  end

end
