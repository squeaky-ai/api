# frozen_string_literal: true

class AddChangelogLastViewedAtToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :changelog_last_viewed_at, :datetime
  end
end
