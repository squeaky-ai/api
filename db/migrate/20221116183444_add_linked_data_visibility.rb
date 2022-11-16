# frozen_string_literal: true

class AddLinkedDataVisibility < ActiveRecord::Migration[7.0]
  def change
    change_table :teams do |t|
      t.boolean :linked_data_visible, default: true, null: false
    end
  end
end
