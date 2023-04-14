# typed: false
# frozen_string_literal: true

class AddDeeplinkDomainToAuth < ActiveRecord::Migration[7.0]
  def change
    change_table :provider_auth do |t|
      t.string :deep_link_url
    end
  end
end
