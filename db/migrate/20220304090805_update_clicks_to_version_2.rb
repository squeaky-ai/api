# frozen_string_literal: true

class UpdateClicksToVersion2 < ActiveRecord::Migration[7.0]
  def change
    # update_view :clicks, version: 2, revert_to_version: 1, materialized: true
  end
end
