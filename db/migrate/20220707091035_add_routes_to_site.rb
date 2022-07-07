# frozen_string_literal: true

class AddRoutesToSite < ActiveRecord::Migration[7.0]
  def change
    change_table :sites do |t|
      t.string :routes, array: true, default: [], null: false
    end
  end
end
