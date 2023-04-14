# typed: false
# frozen_string_literal: true

class AddMissingEventsData < ActiveRecord::Migration[7.0]
  def change
    change_table :clicks do |t|
      t.string :text
      t.bigint :recording_id
    end

    create_table :error_events do |t|
      t.string :filename
      t.string :message, null: false
      t.string :page_url, null: false
      t.bigint :recording_id, null: false

      t.belongs_to :site

      t.timestamps
    end

    create_table :custom_events do |t|
      t.string :name, null: false
      t.jsonb :data, null: false
      t.string :page_url, null: false
      t.bigint :recording_id, null: false

      t.belongs_to :site

      t.timestamps
    end
  end
end
