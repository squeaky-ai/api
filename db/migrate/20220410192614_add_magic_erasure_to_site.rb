# frozen_string_literal: true

class AddMagicErasureToSite < ActiveRecord::Migration[7.0]
  def change
    change_table :sites do |t|
      t.boolean :magic_erasure_enabled, null: false, default: false
    end
  end
end
