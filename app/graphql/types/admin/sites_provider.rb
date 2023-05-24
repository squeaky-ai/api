# frozen_string_literal: true

module Types
  module Admin
    class SitesProvider < Types::BaseObject
      graphql_name 'AdminSitesProvider'

      field :provider_name, String, null: false
      field :count, Integer, null: false
    end
  end
end
