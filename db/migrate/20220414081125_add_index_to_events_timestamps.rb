# frozen_string_literal: true

class AddIndexToEventsTimestamps < ActiveRecord::Migration[7.0]
  def change
    add_index(:events, [:timestamp], order: { timestamp: :asc })
  end
end
