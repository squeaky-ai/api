# typed: false
# frozen_string_literal: true

class AddLastActivityAtToUser < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.datetime :last_activity_at
    end
  end
end
