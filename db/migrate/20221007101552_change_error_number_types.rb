# frozen_string_literal: true

class ChangeErrorNumberTypes < ActiveRecord::Migration[7.0]
  def change
    ClickHouse.connection.modify_column(
      'error_events',
      'col_number',
      type: :Int32
    )

    ClickHouse.connection.modify_column(
      'error_events',
      'line_number',
      type: :Int32
    )
  end
end
