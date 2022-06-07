# frozen_string_literal: true

class AddUniqnessIndexForEventName < ActiveRecord::Migration[7.0]
  def change
    add_index :event_captures, [:name, :site_id], unique: true
  end
end
