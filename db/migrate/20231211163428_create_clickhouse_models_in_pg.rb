# frozen_string_literal: true

class CreateClickhouseModelsInPg < ActiveRecord::Migration[7.1]
  def change
    create_table :click_events, id: :uuid do |t|
      t.string :url
      t.string :selector
      t.string :text
      t.bigint :timestamp
      t.integer :coordinates_x
      t.integer :coordinates_y
      t.integer :viewport_x
      t.integer :viewport_y
      t.integer :device_x
      t.integer :device_y
      t.integer :relative_to_element_x
      t.integer :relative_to_element_y

      t.timestamps

      t.belongs_to :site
      t.belongs_to :recording
      t.belongs_to :visitor
    end

    create_table :cursor_events, id: :uuid do |t|
      t.string :url
      t.string :coordinates
      t.integer :viewport_x
      t.integer :viewport_y
      t.integer :device_x
      t.integer :device_y
      t.bigint :timestamp

      t.timestamps

      t.belongs_to :site
      t.belongs_to :recording
      t.belongs_to :visitor
    end

    create_table :custom_events, id: :uuid do |t|
      t.string :name
      t.string :data
      t.string :url
      t.string :source
      t.integer :viewport_x
      t.integer :viewport_y
      t.integer :device_x
      t.integer :device_y
      t.bigint :timestamp

      t.timestamps

      t.belongs_to :site
      t.belongs_to :recording
      t.belongs_to :visitor
    end

    create_table :error_events, id: :uuid do |t|
      t.string :filename
      t.string :message
      t.string :url
      t.string :stack
      t.bigint :timestamp
      t.integer :line_number
      t.integer :col_number
      t.integer :viewport_x
      t.integer :viewport_y
      t.integer :device_x
      t.integer :device_y

      t.timestamps

      t.belongs_to :site
      t.belongs_to :recording
      t.belongs_to :visitor
    end

    create_table :page_events, id: :uuid do |t|
      t.string :url
      t.bigint :entered_at
      t.bigint :exited_at
      t.bigint :duration
      t.bigint :activity_duration
      t.boolean :bounced_on
      t.boolean :exited_on
      t.integer :viewport_x
      t.integer :viewport_y
      t.integer :device_x
      t.integer :device_y

      t.timestamps

      t.belongs_to :site
      t.belongs_to :recording
      t.belongs_to :visitor
    end

    create_table :scroll_events, id: :uuid do |t|
      t.string :url
      t.bigint :timestamp
      t.integer :x
      t.integer :y
      t.integer :viewport_x
      t.integer :viewport_y
      t.integer :device_x
      t.integer :device_y

      t.timestamps

      t.belongs_to :site
      t.belongs_to :recording
      t.belongs_to :visitor
    end
  end
end
