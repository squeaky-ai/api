# frozen_string_literal: true

class AddIndexToVisitorUserId < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :visitors, 
      "site_id, (external_attributes->>'id')",
      name: 'index_visitors_on_external_attributes_id', 
      algorithm: :concurrently
  end
end
