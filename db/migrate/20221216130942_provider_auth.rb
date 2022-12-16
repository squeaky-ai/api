# frozen_string_literal: true

class ProviderAuth < ActiveRecord::Migration[7.0]
  def change
    create_table :provider_auth do |t|
      t.string :provider
      t.string :provider_uuid
      t.string :auth_type
      t.string :access_token
      t.string :refresh_token
      t.string :api_endpoint
      t.bigint :expires_at

      t.belongs_to :site
    end
  end
end
