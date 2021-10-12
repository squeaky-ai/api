# frozen_string_literal: true

class AddDomainBlacklist < ActiveRecord::Migration[6.1]
  def change
    change_table :sites do |t|
      t.jsonb :domain_blacklist, null: false, default: []
    end
  end
end
