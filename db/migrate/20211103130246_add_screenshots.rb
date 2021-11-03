# frozen_string_literal: true

class AddScreenshots < ActiveRecord::Migration[6.1]
  def change
    create_table :screenshots do |t|
      t.string :url
      t.string :image_url

      t.belongs_to :site

      t.timestamps
    end
  end
end
