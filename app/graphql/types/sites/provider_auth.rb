# typed: false
# frozen_string_literal: true

module Types
  module Sites
    class ProviderAuth < Types::BaseObject
      graphql_name 'SitesProviderAuth'

      field :id, ID, null: false
      field :provider, String, null: false
      field :provider_uuid, String, null: false
      field :auth_type, String, null: false
      field :api_endpoint, String, null: true
      field :provider_app_uuid, String, null: true
      field :sdk_url, String, null: true
    end
  end
end
