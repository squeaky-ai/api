# frozen_string_literal: true

class CreateEventsAgain < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :events, null: false, array: true, default: []

      t.belongs_to :recording

      t.timestamps
    end
  end
end
