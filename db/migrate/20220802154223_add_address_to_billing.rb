# frozen_string_literal: true

class AddAddressToBilling < ActiveRecord::Migration[7.0]
  def change
    change_table :billing do |t|
      t.jsonb :billing_address
    end
  end
end
