# frozen_string_literal: true

class CreateSentiment < ActiveRecord::Migration[6.1]
  def change
    create_table :sentiments do |t|
      t.integer :score, null: false
      t.string :comment

      t.belongs_to :recording

      t.timestamps
    end
  end
end
