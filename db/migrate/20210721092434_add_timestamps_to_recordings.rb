# frozen_string_literal: true

class AddTimestampsToRecordings < ActiveRecord::Migration[6.1]
  def change
    change_table :recordings do |t|
      t.bigint :connected_at
      t.bigint :disconnected_at
      t.string :page_views, null: false, array: true, default: []
      t.string :locale
      t.boolean :active, default: false
      t.string :useragent
      t.integer :viewport_x
      t.integer :viewport_y
    end
  end
end
