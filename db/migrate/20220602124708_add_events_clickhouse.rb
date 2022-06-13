# frozen_string_literal: true

class AddEventsClickhouse < ActiveRecord::Migration[7.0]
  def up
    ClickHouse.connection.create_table(
      'events', 
      engine: 'MergeTree',
      order: '(site_id, timestamp)'
    ) do |t|
      t.UUID   :uuid
      t.Int64  :site_id
      t.Int64  :recording_id
      t.Int16  :type
      t.Int16  :source, nullable: true
      t.String :data
      t.Int64  :timestamp
    end
  end

  def down
    ClickHouse.connection.drop_table('events')
  end
end