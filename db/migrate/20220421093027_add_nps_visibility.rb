# typed: false
# frozen_string_literal: true

class AddNpsVisibility < ActiveRecord::Migration[7.0]
  def change
    change_table :feedback do |t|
      t.string :nps_excluded_pages, null: false, array: true, default: []
    end
  end
end
