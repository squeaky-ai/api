# frozen_string_literal: true

class AddStackToErrorEvents < ActiveRecord::Migration[7.0]
  def up
    ClickHouse.connection.add_column(
      'error_events',
      'stack',
      :String
    )
  end

  def down
    ClickHouse.connection.drop_column(
      'error_events',
      'stack'
    )
  end
end
