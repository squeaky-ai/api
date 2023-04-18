# frozen_string_literal: true

class AddAnonymiseTextToSites < ActiveRecord::Migration[7.0]
  def change
    change_table :sites do |t|
      t.boolean :anonymise_text, null: false, default: false
    end
  end
end
