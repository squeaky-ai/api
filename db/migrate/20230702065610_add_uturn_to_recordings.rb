# frozen_string_literal: true

class AddUturnToRecordings < ActiveRecord::Migration[7.0]
  def up
    add_column :recordings, :u_turned, :boolean, default: false

    ClickHouse.connection.add_column(
      'recordings',
      'u_turned',
      :Boolean,
      if_not_exists: true,
      default: false
    )
  end


  def down
    remove_column :recordings, :u_turned

    ClickHouse.connection.drop_column(
      'recordings',
      'u_turned'
    )
  end
end
