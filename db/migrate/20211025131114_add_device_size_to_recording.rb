# typed: false
# frozen_string_literal: true

class AddDeviceSizeToRecording < ActiveRecord::Migration[6.1]
  def change
    change_table :recordings do |t|
      t.integer :device_x, null: false, default: -1
      t.integer :device_y, null: false, default: -1
    end
  end
end
