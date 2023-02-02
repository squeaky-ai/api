# frozen_string_literal: true

class AddSourceToVisitor < ActiveRecord::Migration[7.0]
  def change
    change_table :visitors do |t|
      t.string :source
    end
  end
end
