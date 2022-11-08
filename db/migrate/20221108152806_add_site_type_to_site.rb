# frozen_string_literal: true

class AddSiteTypeToSite < ActiveRecord::Migration[7.0]
  def change
    change_table :sites do |t|
      t.integer :site_type
    end
  end
end
