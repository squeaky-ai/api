# frozen_string_literal: true

class AddScrollsAndCursorsToClickhouse < ActiveRecord::Migration[7.0]
  def up
    ClickHouse.connection.create_table(
      'scroll_events', 
      engine: 'MergeTree',
      order: '(site_id, toDate(timestamp))'
    ) do |t|
      t.UUID   :uuid
      t.Int64  :site_id
      t.Int64  :recording_id
      t.String :url
      t.Int16  :x
      t.Int16  :y
      t.Int16  :viewport_x
      t.Int16  :viewport_y
      t.Int16  :device_x
      t.Int16  :device_y
      t.Int64  :timestamp
    end

    ClickHouse.connection.create_table(
      'cursor_events', 
      engine: 'MergeTree',
      order: '(site_id, toDate(timestamp))'
    ) do |t|
      t.UUID   :uuid
      t.Int64  :site_id
      t.Int64  :recording_id
      t.String :url
      t.String :coordinates
      t.Int16  :viewport_x
      t.Int16  :viewport_y
      t.Int16  :device_x
      t.Int16  :device_y
      t.Int64  :timestamp
    end
  end

  def down
    ClickHouse.connection.drop_table('scroll_events')
    ClickHouse.connection.drop_table('cursor_events')
  end
end
