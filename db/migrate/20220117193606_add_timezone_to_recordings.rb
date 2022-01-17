# frozen_string_literal: true

class AddTimezoneToRecordings < ActiveRecord::Migration[7.0]
  def change
    change_table :recordings do |t|
      t.string :timezone
      t.string :country_code
    end
  end
end
