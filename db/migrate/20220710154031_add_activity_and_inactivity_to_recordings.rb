# frozen_string_literal: true

class AddActivityAndInactivityToRecordings < ActiveRecord::Migration[7.0]
  def change
    change_table :recordings do |t|
      t.bigint :activity_duration
      t.string :inactivity, array: true, default: [], null: false
    end
  end
end
