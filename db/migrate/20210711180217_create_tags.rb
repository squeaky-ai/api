# typed: false
# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[6.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false

      t.belongs_to :recording

      t.timestamps
    end
  end
end
