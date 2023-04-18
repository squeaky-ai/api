# frozen_string_literal: true

class CreateFeedback < ActiveRecord::Migration[6.1]
  def change
    create_table :feedback do |t|
      t.boolean :nps_enabled, null: false, default: false
      t.string :nps_accent_color
      t.string :nps_schedule
      t.string :nps_phrase
      t.boolean :nps_follow_up_enabled
      t.boolean :nps_contact_consent_enabled
      t.string :nps_layout

      t.boolean :sentiment_enabled, null: false, default: false
      t.string :sentiment_accent_color
      t.string :sentiment_excluded_pages, null: false, array: true, default: []
      t.string :sentiment_layout

      t.belongs_to :site

      t.timestamps
    end
  end
end
