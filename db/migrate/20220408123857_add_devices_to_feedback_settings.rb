# frozen_string_literal: true

class AddDevicesToFeedbackSettings < ActiveRecord::Migration[7.0]
  def change
    change_table :feedback do |t|
      t.string :sentiment_devices, null: false, array: true, default: []
    end
  end
end
