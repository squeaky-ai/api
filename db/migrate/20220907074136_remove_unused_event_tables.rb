# frozen_string_literal: true

class RemoveUnusedEventTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :error_events
    drop_table :custom_events

    ClickHouse.connection.drop_table('events')
  end
end
