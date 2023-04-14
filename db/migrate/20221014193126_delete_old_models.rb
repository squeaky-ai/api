# typed: false
# frozen_string_literal: true

class DeleteOldModels < ActiveRecord::Migration[7.0]
  def change
    drop_table :clicks
  end
end
