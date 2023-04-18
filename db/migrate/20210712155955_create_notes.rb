# typed: false
# frozen_string_literal: true

class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.string :body
      t.integer :timestamp

      t.belongs_to :user
      t.belongs_to :recording

      t.timestamps
    end
  end
end
