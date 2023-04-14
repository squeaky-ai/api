# typed: false
# frozen_string_literal: true

class AddAliasToEventCaptures < ActiveRecord::Migration[7.0]
  def change
    change_table :event_captures do |t|
      t.string :name_alias
    end
  end
end
