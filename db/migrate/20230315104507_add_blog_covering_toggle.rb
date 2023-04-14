# typed: false
# frozen_string_literal: true

class AddBlogCoveringToggle < ActiveRecord::Migration[7.0]
  def change
    change_table :blog do |t|
      t.boolean :covering_enabled, default: true
    end
  end
end
