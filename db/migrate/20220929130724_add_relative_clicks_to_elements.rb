# typed: false
# frozen_string_literal: true

class AddRelativeClicksToElements < ActiveRecord::Migration[7.0]
  def up
    ClickHouse.connection.add_column(
      'click_events',
      'relative_to_element_x',
      :Int16,
      if_not_exists: true
    )

    ClickHouse.connection.add_column(
      'click_events',
      'relative_to_element_y',
      :Int16,
      if_not_exists: true
    )
  end

  def down
    ClickHouse.connection.drop_column(
      'click_events',
      'relative_to_element_x'
    )

    ClickHouse.connection.drop_column(
      'click_events',
      'relative_to_element_y'
    )
  end
end
