# frozen_string_literal: true

class AddPublishToProviderAuth < ActiveRecord::Migration[7.1]
  def change
    change_table :provider_auth do |t|
      t.string :publish_history, array: true, default: []
    end
  end
end
