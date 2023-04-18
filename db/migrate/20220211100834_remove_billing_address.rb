# frozen_string_literal: true

class RemoveBillingAddress < ActiveRecord::Migration[7.0]
  def change
    remove_column :billing, :billing_address
  end
end
