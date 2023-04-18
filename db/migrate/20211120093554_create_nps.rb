# frozen_string_literal: true

class CreateNps < ActiveRecord::Migration[6.1]
  def change
    create_table :nps do |t|
      t.integer :score, null: false
      t.string :comment
      t.boolean :contact, null: false, default: false

      t.belongs_to :recording

      t.timestamps
    end
  end
end
