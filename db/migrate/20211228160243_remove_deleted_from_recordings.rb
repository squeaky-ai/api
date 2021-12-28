# frozen_string_literal: true

class RemoveDeletedFromRecordings < ActiveRecord::Migration[6.1]
  def change
    remove_column :recordings, :deleted
  end
end
