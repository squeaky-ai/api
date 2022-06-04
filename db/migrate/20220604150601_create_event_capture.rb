# frozen_string_literal: true

class CreateEventCapture < ActiveRecord::Migration[7.0]
  def change
    create_table :event_captures do |t|
      t.string :name, null: false
      t.integer :event_type, null: false
      t.integer :count, null: false, default: 0
      t.json :rules, null: false, default: []
      t.datetime :last_counted_at

      t.belongs_to :site

      t.timestamps
    end

    create_table :event_groups do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_join_table :event_captures, :event_groups
  end
end
