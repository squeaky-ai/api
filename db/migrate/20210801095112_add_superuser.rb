# frozen_string_literal: true

class AddSuperuser < ActiveRecord::Migration[6.1]
  def change
    change_table :users do |t|
      t.boolean :superuser, default: false
    end
  end
end
