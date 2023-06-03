# frozen_string_literal: true

class AddViewedToClickhouseRecordings < ActiveRecord::Migration[7.0]
  def up
    ClickHouse.connection.add_column(
      'recordings',
      'viewed',
      :Boolean,
      if_not_exists: true,
      default: nil
    )

    ClickHouse.connection.add_column(
      'recordings',
      'bookmarked',
      :Boolean,
      if_not_exists: true,
      default: nil
    )
  end


  def down
    ClickHouse.connection.drop_column(
      'recordings',
      'viewed'
    )

    ClickHouse.connection.drop_column(
      'recordings',
      'bookmarked'
    )
  end
end
