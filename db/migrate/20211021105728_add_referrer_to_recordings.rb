# typed: false
# frozen_string_literal: true

class AddReferrerToRecordings < ActiveRecord::Migration[6.1]
  def change
    change_table :recordings do |t|
      t.string :referrer, null: true
    end

    remove_column :recordings, :page_views
  end
end
