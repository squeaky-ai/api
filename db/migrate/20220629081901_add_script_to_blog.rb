# frozen_string_literal: true

class AddScriptToBlog < ActiveRecord::Migration[7.0]
  def change
    change_table :blog do |t|
      t.string :scripts, null: false, array: true, default: []
    end
  end
end
