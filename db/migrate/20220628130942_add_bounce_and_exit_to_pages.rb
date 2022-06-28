# frozen_string_literal: true

class AddBounceAndExitToPages < ActiveRecord::Migration[7.0]
  def change
    change_table :pages do |t|
      t.boolean :exited_on, null: false, default: false
      t.boolean :bounced_on, null: false, default: false
    end
  end
end
