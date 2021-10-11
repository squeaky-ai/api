# frozen_string_literal: true

class AddIpBlacklist < ActiveRecord::Migration[6.1]
  def change
    change_table :sites do |t|
      t.jsonb :ip_blacklist, null: false, default: []
    end
  end
end
