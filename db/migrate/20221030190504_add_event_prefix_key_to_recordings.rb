# frozen_string_literal: true

class AddEventPrefixKeyToRecordings < ActiveRecord::Migration[7.0]
  def change
    change_table :recordings do |t|
      t.string :events_key_prefix
    end
  end
end
