# frozen_string_literal: true

class AddDiscountToTransaction < ActiveRecord::Migration[7.0]
  def change
    change_table :transactions do |t|
      t.string :discount_name
      t.float :discount_percentage
      t.string :discount_id
    end
  end
end
