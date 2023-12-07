# frozen_string_literal: true

class DropChangelog < ActiveRecord::Migration[7.1]
  def change
    drop_table :changelog
    remove_column :users, :changelog_last_viewed_at
  end
end
