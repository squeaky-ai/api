# frozen_string_literal: true

class AddRageClickToRecordings < ActiveRecord::Migration[7.0]
  def up
    add_column :recordings, :rage_clicked, :boolean, default: false

    ClickHouse.connection.add_column(
      'recordings',
      'rage_clicked',
      :Boolean,
      if_not_exists: true,
      default: false
    )
  end


  def down
    drop_column :recordings, :rage_clicked

    ClickHouse.connection.drop_column(
      'recordings',
      'rage_clicked'
    )
  end
end
