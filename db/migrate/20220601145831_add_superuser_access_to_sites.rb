# typed: false
# frozen_string_literal: true

class AddSuperuserAccessToSites < ActiveRecord::Migration[7.0]
  def change
    change_table :sites do |t|
      t.boolean :superuser_access_enabled, default: false
    end
  end
end
