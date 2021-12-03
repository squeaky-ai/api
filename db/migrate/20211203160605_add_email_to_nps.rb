# frozen_string_literal: true

class AddEmailToNps < ActiveRecord::Migration[6.1]
  def change
    change_table :nps do |t|
      t.string :email, null: true
    end
  end
end
