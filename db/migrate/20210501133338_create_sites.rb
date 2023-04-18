# typed: false
# frozen_string_literal: true

class CreateSites < ActiveRecord::Migration[6.1]
  def change
    create_table :sites do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :avatar
      t.string :uuid, null: false
      t.integer :plan, null: false
      t.datetime :checklist_dismissed_at
      t.datetime :verified_at

      t.timestamps
    end

    add_index :sites, :url, unique: true
    add_index :sites, :uuid, unique: true
  end
end
