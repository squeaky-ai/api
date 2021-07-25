# frozen_string_literal: true

class RecordingIdUnique < ActiveRecord::Migration[6.1]
  def change
    remove_index :events, [:recording_id]
    add_index :events, :recording_id, unique: true
  end
end
