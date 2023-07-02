# frozen_string_literal: true

class AddDurationToPages < ActiveRecord::Migration[7.0]
  def up
    add_column :pages, :duration, :bigint
    add_column :pages, :activity_duration, :bigint

    ClickHouse.connection.add_column(
      'page_events',
      'duration',
      :Int64,
      if_not_exists: true
    )

    ClickHouse.connection.add_column(
      'page_events',
      'activity_duration',
      :Int64,
      if_not_exists: true
    )
  end

  def down
    remove_column :pages, :duration
    remove_column :pages, :activity_duration

    ClickHouse.connection.drop_column(
      'page_events',
      'duration'
    )

    ClickHouse.connection.drop_column(
      'page_events',
      'activity_duration'
    )
  end
end
