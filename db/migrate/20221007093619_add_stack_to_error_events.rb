# frozen_string_literal: true

class AddStackToErrorEvents < ActiveRecord::Migration[7.0]
  def up
    ClickHouse.connection.add_column(
      'error_events',
      'stack',
      :String
    )

    ClickHouse.connection.add_column(
      'error_events',
      'col_number',
      :Int16
    )

    ClickHouse.connection.add_column(
      'error_events',
      'line_number',
      :Int16
    )
  end

  def down
    ClickHouse.connection.drop_column(
      'error_events',
      'stack'
    )

    ClickHouse.connection.drop_column(
      'error_events',
      'col_number'
    )

    ClickHouse.connection.drop_column(
      'error_events',
      'line_number'
    )
  end
end
