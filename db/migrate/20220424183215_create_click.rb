# typed: false
# frozen_string_literal: true

class CreateClick < ActiveRecord::Migration[7.0]
  def change
    # drop_view :clicks, materialized: true

    create_table :clicks do |t|
      t.string :selector, null: false
      t.integer :coordinates_x, null: false
      t.integer :coordinates_y, null: false
      t.string :page_url, null: false
      t.bigint :clicked_at, null: false
      t.integer :viewport_x, null: false
      t.integer :viewport_y, null: false

      t.belongs_to :site

      t.timestamps
    end
  end
end
