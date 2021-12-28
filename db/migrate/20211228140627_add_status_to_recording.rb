# frozen_string_literal: true

class AddStatusToRecording < ActiveRecord::Migration[6.1]
  def change
    change_table :recordings do |t|
      t.integer :status
    end
  end
end
