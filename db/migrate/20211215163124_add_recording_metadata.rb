# frozen_string_literal: true

class AddRecordingMetadata < ActiveRecord::Migration[6.1]
  def change
    change_table :recordings do |t|
      t.string :browser
      t.string :device_type
    end
  end
end
