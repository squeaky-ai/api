# frozen_string_literal: true

class AddMoreClickhouseTables < ActiveRecord::Migration[7.0]
  def up
    ClickHouse.connection.create_table(
      'page_events',
      engine: 'MergeTree',
      order: '(site_id, toDate(exited_at))',
      if_not_exists: true
    ) do |t|
      t.UUID   :uuid
      t.Int64  :site_id
      t.Int64  :recording_id
      t.String :url
      t.Int16  :viewport_x
      t.Int16  :viewport_y
      t.Int16  :device_x
      t.Int16  :device_y
      t.Int64  :entered_at
      t.Int64  :exited_at
      t.Int8   :exited_on
      t.Int8   :bounced_on
    end

    ClickHouse.connection.create_table(
      'click_events',
      engine: 'MergeTree',
      order: '(site_id, toDate(timestamp))',
      if_not_exists: true
    ) do |t|
      t.UUID   :uuid
      t.Int64  :site_id
      t.Int64  :recording_id
      t.String :url
      t.String :selector
      t.String :text
      t.Int16  :coordinates_x
      t.Int16  :coordinates_y
      t.Int16  :viewport_x
      t.Int16  :viewport_y
      t.Int16  :device_x
      t.Int16  :device_y
      t.Int64  :timestamp
    end

    ClickHouse.connection.create_table(
      'error_events',
      engine: 'MergeTree',
      order: '(site_id, toDate(timestamp))',
      if_not_exists: true
    ) do |t|
      t.UUID   :uuid
      t.Int64  :site_id
      t.Int64  :recording_id
      t.String :filename
      t.String :message
      t.String :url
      t.Int16  :viewport_x
      t.Int16  :viewport_y
      t.Int16  :device_x
      t.Int16  :device_y
      t.Int64  :timestamp
    end

    ClickHouse.connection.create_table(
      'custom_events',
      engine: 'MergeTree',
      order: '(site_id, toDate(timestamp))',
      if_not_exists: true
    ) do |t|
      t.UUID   :uuid
      t.Int64  :site_id
      t.Int64  :recording_id
      t.String :name
      t.String :data
      t.String :url
      t.Int16  :viewport_x
      t.Int16  :viewport_y
      t.Int16  :device_x
      t.Int16  :device_y
      t.Int64  :timestamp
    end
  end

  def down
    ClickHouse.connection.drop_table('page_events')
    ClickHouse.connection.drop_table('click_events')
    ClickHouse.connection.drop_table('error_events')
    ClickHouse.connection.drop_table('custom_events')
  end
end
