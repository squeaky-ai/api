# frozen_string_literal: true

class ChangeRecording < ActiveRecord::Migration[6.1]
  def change
    change_table :recordings do |t|
      t.remove :page_views, :connected_at, :disconnected_at, :viewport_x, :viewport_y
    end
  end
end
