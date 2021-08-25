# frozen_string_literal: true

class UpdateVisitors < ActiveRecord::Migration[6.1]
  def change
    change_table :visitors do |t|
      t.jsonb :external_attributes, null: false, default: '{}'
    end

    remove_column :visitors, :external_id
  end
end
