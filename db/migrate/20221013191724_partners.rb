# frozen_string_literal: true

class Partners < ActiveRecord::Migration[7.0]
  def change
    create_table :partners do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.belongs_to :user

      t.timestamps
    end
  end
end
