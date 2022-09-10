# frozen_string_literal: true

class AddRecordingsToClickhouse < ActiveRecord::Migration[7.0]
  def up
    ClickHouse.connection.create_table(
      'recordings', 
      engine: 'MergeTree',
      order: '(site_id, toDate(disconnected_at))'
    ) do |t|
      t.UUID   :uuid
      t.Int64  :site_id
      t.Int64  :recording_id
      t.String :session_id
      t.String :locale, nullable: true
      t.String :useragent, nullable: true
      t.Int16  :viewport_x
      t.Int16  :viewport_y
      t.Int64  :connected_at
      t.Int64  :disconnected_at
      t.Int64  :visitor_id
      t.String :referrer, nullable: true
      t.Int16  :device_x
      t.Int16  :device_y
      t.String :browser, nullable: true
      t.String :device_type, nullable: true
      t.String :timezone, nullable: true
      t.String :country_code, nullable: true
      t.String :utm_source, nullable: true
      t.String :utm_medium, nullable: true
      t.String :utm_campaign, nullable: true
      t.String :utm_content, nullable: true
      t.String :utm_term, nullable: true
      t.Int64  :activity_duration
      t.String :inactivity
    end
  end
  
  def down
    ClickHouse.connection.drop_table('recordings')
  end
end
