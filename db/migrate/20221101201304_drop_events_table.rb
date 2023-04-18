# typed: false
# frozen_string_literal: true

class DropEventsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :events
  end
end
