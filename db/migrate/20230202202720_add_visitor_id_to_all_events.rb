# frozen_string_literal: true

class AddVisitorIdToAllEvents < ActiveRecord::Migration[7.0]
  def up
    ClickHouse.connection.add_column(
      'click_events',
      'visitor_id',
      :Int64,
      if_not_exists: true
    )

    ClickHouse.connection.add_column(
      'error_events',
      'visitor_id',
      :Int64,
      if_not_exists: true
    )

    ClickHouse.connection.add_column(
      'page_events',
      'visitor_id',
      :Int64,
      if_not_exists: true
    )
  end

  def down
    ClickHouse.connection.drop_column(
      'click_events',
      'visitor_id'
    )

    ClickHouse.connection.drop_column(
      'error_events',
      'visitor_id'
    )

    ClickHouse.connection.drop_column(
      'page_events',
      'visitor_id'
    )
  end
end
