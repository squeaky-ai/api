# frozen_string_literal: true

class AddBlacklistedCssSelectorsToSites < ActiveRecord::Migration[7.0]
  def change
    change_table :sites do |t|
      t.string :css_selector_blacklist, null: false, array: true, default: []
    end
  end
end
