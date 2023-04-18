# frozen_string_literal: true

class AddEventApi < ActiveRecord::Migration[7.0]
  def up
    add_column :sites, :api_key, :string

    ClickHouse.connection.add_column(
      'custom_events',
      'visitor_id',
      :Int64,
      if_not_exists: true
    )

    ClickHouse.connection.add_column(
      'custom_events',
      'source',
      :String,
      if_not_exists: true
    )
  end

  def down
    drop_column :sites, :api_key

    ClickHouse.connection.drop_column(
      'custom_events',
      'visitor_id'
    )

    ClickHouse.connection.drop_column(
      'custom_events',
      'source'
    )
  end
end
