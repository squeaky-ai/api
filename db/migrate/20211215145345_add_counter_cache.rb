# frozen_string_literal: true

class AddCounterCache < ActiveRecord::Migration[6.1]
  def change
    change_table :recordings do |t|
      t.integer :pages_count
    end

    change_table :visitors do |t|
      t.integer :recordings_count
    end
  end
end
