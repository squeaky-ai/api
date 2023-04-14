# typed: false
# frozen_string_literal: true

class AddIngestToSite < ActiveRecord::Migration[7.0]
  def change
    change_table :sites do |t|
      t.boolean :ingest_enabled, null: false, default: true
    end
  end
end
