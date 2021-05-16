# frozen_string_literal: true

class CreateRecordings < ActiveRecord::Migration[6.1]
  def change
    create_table :recordings do |t|
      t.string :session_id, null: false
      t.string :viewer_id, null: false
      t.string :locale, null: false
      t.string :start_page, null: false
      t.string :exit_page, null: false
      t.string :useragent, null: false
      t.string :viewport_x, null: false
      t.string :viewport_y, null: false
      t.string :page_views, array: true, default: []

      t.belongs_to :site

      t.timestamps
    end
  end
end
