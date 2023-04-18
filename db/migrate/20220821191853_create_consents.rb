# frozen_string_literal: true

class CreateConsents < ActiveRecord::Migration[7.0]
  def change
    create_table :consents do |t|
      t.string :name
      t.string :privacy_policy_url
      t.string :layout
      t.string :consent_method
      t.string :languages, array: true, default: [], null: false
      t.string :languages_default

      t.belongs_to :site

      t.timestamps
    end
  end
end
