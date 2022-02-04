# frozen_string_literal: true

class AddStatusToCustomer < ActiveRecord::Migration[7.0]
  def change
    change_table :customers do |t|
      t.string :status, null: false, default: 'new'
    end
  end
end
