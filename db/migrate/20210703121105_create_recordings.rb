# frozen_string_literal: true

class CreateRecordings < ActiveRecord::Migration[6.1]
  def change
    create_table :recordings do |t|
      t.string :session_id, null: false
      t.string :viewer_id, null: false
      t.boolean :viewed, default: false
      t.boolean :bookmarked, default: false
      t.string :locale, null: false
      t.string :page_views, null: false, array: true, default: []
      t.string :useragent, null: false
      t.integer :viewport_x, null: false
      t.integer :viewport_y, null: false
      t.bigint :connected_at, null: false
      t.bigint :disconnected_at, null: false

      t.belongs_to :site

      t.timestamps
    end

    add_index :recordings, :session_id, unique: true
  end
end
