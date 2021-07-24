# frozen_string_literal: true

class AddRecordingMeta < ActiveRecord::Migration[6.1]
  def change
    change_table :recordings do |t|
      t.boolean :viewed, default: false
      t.boolean :bookmarked, default: false
    end
  end
end
