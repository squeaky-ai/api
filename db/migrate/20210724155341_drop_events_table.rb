# frozen_string_literal: true

class DropEventsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :events
  end
end