# typed: false
# frozen_string_literal: true

class AddNewToVisitor < ActiveRecord::Migration[7.0]
  def change
    change_table :visitors do |t|
      t.boolean :new, default: true
    end
  end
end
