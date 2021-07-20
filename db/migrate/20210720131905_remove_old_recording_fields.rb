# frozen_string_literal: true

class RemoveOldRecordingFields < ActiveRecord::Migration[6.1]
  def change
    change_table :recordings do |t|
      t.remove :useragent, :locale
    end
  end
end
