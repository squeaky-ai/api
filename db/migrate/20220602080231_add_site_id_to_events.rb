# frozen_string_literal: true

class AddSiteIdToEvents < ActiveRecord::Migration[7.0]
  def change
    change_table :events do |t|
      t.bigint :site_id
    end

    add_index :events, :site_id
  end
end
