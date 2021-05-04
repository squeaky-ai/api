# frozen_string_literal: true

class CreateSites < ActiveRecord::Migration[6.1]
  def change
    create_table :sites do |t|
      t.string :name
      t.string :url
      t.string :avatar
      t.string :uuid, null: false
      t.integer :plan, null: false
      t.datetime :verified_at

      t.timestamps
    end

    add_index :sites, :url, unique: true
  end
end
