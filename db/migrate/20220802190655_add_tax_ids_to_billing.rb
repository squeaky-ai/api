# frozen_string_literal: true

class AddTaxIdsToBilling < ActiveRecord::Migration[7.0]
  def change
    change_table :billing do |t|
      t.jsonb :tax_ids, null: false, default: []
    end
  end
end
