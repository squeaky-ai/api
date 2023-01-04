# frozen_string_literal: true

class AddActiveEventCount < ActiveRecord::Migration[7.0]
  def up
    add_column :recordings, :active_events_count, :integer

    ClickHouse.connection.add_column(
      'recordings',
      'active_events_count',
      :Int16,
      if_not_exists: true
    )
  end

  def down
    drop_column :recordings, :active_events_count

    ClickHouse.connection.drop_column(
      'recordings',
      'active_events_count'
    )
  end
end
