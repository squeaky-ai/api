# frozen_string_literal: true

class AddBlog < ActiveRecord::Migration[7.0]
  def change
    create_table :blog do |t|
      t.string :title, null: false
      t.string :tags, array: true, default: []
      t.string :author, null: false
      t.string :category, null: false
      t.boolean :draft, null: false, default: true
      t.string :meta_image, null: false
      t.string :meta_description, null: false
      t.string :slug, null: false
      t.string :body, null: false

      t.timestamps
    end
  end
end
