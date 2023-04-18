# typed: false
# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string :customer_id

      t.belongs_to :user
      t.belongs_to :site

      t.timestamps
    end
  end
end
