# typed: false
# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.integer :event_type, null: false
      t.jsonb :data, null: false
      t.bigint :timestamp, null: false

      t.belongs_to :recording

      t.timestamps
    end
  end
end
