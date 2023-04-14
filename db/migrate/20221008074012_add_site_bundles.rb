# typed: false
# frozen_string_literal: true

class AddSiteBundles < ActiveRecord::Migration[7.0]
  def change
    create_table :site_bundles do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :site_bundles_sites do |t|
      t.boolean :primary, null: false
      t.belongs_to :site_bundle
      t.belongs_to :site

      t.timestamps
    end
  end
end
