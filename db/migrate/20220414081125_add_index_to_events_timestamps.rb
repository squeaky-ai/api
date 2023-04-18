# typed: false
# frozen_string_literal: true

class AddIndexToEventsTimestamps < ActiveRecord::Migration[7.0]
  def change
    add_index(:events, %i[recording_id timestamp], order: { timestamp: :asc })
  end
end
