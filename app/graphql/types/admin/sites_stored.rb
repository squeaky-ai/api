# frozen_string_literal: true

module Types
  module Admin
    class SitesStored < Types::BaseObject
      graphql_name 'AdminSitesStored'

      field :all_count, Integer, null: false
      field :verified_count, Integer, null: false
      field :unverified_count, Integer, null: false
      field :date, GraphQL::Types::ISO8601Date, null: false
    end
  end
end
