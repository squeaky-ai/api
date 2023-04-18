# typed: false
# frozen_string_literal: true

class AddBillingToCustomer < ActiveRecord::Migration[7.0]
  def change
    change_table :customers do |t|
      t.string :card_type
      t.string :country
      t.string :expiry
      t.string :card_number
      t.string :billing_address
      t.string :billing_name
      t.string :billing_email
    end
  end
end
