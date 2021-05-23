# frozen_string_literal: true

class ChangeRecordings < ActiveRecord::Migration[6.1]
  def change
    remove_column :recordings, :start_page
    remove_column :recordings, :exit_page
    add_column :recordings, :events, :jsonb, null: false, default: []
  end
end
