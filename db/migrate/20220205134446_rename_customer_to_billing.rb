# frozen_string_literal: true

class RenameCustomerToBilling < ActiveRecord::Migration[7.0]
  def change
    rename_table :customers, :billing
  end
end
