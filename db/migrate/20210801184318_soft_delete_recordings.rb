# typed: false
# frozen_string_literal: true

class SoftDeleteRecordings < ActiveRecord::Migration[6.1]
  def change
    change_table :recordings do |t|
      t.boolean :deleted, default: false
    end
  end
end
