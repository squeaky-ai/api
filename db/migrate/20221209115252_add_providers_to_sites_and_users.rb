# typed: false
# frozen_string_literal: true

class AddProvidersToSitesAndUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :sites do |t|
      t.string :provider
    end

    change_table :users do |t|
      t.string :provider
      t.string :provider_uuid
    end
  end
end
