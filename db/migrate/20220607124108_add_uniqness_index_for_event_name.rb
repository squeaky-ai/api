# typed: false
# frozen_string_literal: true

class AddUniqnessIndexForEventName < ActiveRecord::Migration[7.0]
  def change
    add_index :event_captures, %i[name site_id], unique: true
  end
end
