# frozen_string_literal: true

class AddSourceToEventCapture < ActiveRecord::Migration[7.0]
  def change
    change_table :event_captures do |t|
      t.string :source
    end
  end
end
