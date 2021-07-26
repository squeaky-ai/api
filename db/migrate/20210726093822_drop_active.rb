# frozen_string_literal: true

class DropActive < ActiveRecord::Migration[6.1]
  def change
    change_table :recordings do |t|
      t.remove :active
    end
  end
end
