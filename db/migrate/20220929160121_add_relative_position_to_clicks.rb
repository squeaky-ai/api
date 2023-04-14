# typed: false
# frozen_string_literal: true

class AddRelativePositionToClicks < ActiveRecord::Migration[7.0]
  def change
    change_table :clicks do |t|
      t.integer :relative_to_element_x
      t.integer :relative_to_element_y
    end
  end
end
