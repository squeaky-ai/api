# frozen_string_literal: true

class AddStatusToClickhouseRecording < ActiveRecord::Migration[7.1]
  def up
    ClickHouse.connection.add_column(
      'recordings',
      'status',
      :Int16,
      if_not_exists: true
    )
  end


  def down
    ClickHouse.connection.drop_column(
      'recordings',
      'status'
    )
  end
end
