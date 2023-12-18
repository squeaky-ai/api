# frozen_string_literal: true

class DropPgEventTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :click_events
    drop_table :error_events
    drop_table :custom_events
    drop_table :page_events
    drop_table :cursor_events
    drop_table :scroll_events
  end
end
