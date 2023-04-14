# typed: false
# frozen_string_literal: true

class AddDiscountAmountToTransaction < ActiveRecord::Migration[7.0]
  def change
    change_table :transactions do |t|
      t.integer :discount_amount
    end
  end
end
