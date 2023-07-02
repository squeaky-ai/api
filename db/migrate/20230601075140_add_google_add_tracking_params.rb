# frozen_string_literal: true

class AddGoogleAddTrackingParams < ActiveRecord::Migration[7.0]
  def up
    add_column :recordings, :gad, :string
    add_column :recordings, :gclid, :string

    ClickHouse.connection.add_column(
      'recordings',
      'gad',
      :String,
      if_not_exists: true
    )

    ClickHouse.connection.add_column(
      'recordings',
      'gclid',
      :String,
      if_not_exists: true
    )
  end


  def down
    remove_column :recordings, :gad
    remove_column :recordings, :gclid

    ClickHouse.connection.drop_column(
      'recordings',
      'gad'
    )

    ClickHouse.connection.drop_column(
      'recordings',
      'gclid'
    )
  end
end
