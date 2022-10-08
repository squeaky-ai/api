# frozen_string_literal: true

module Types
  module Sites
    class Bundle < Types::BaseObject
      graphql_name 'SitesBundle'

      field :id, ID, null: false
      field :name, String, null: false
      field :plan, Types::Sites::Plan, null: false
      field :sites, [Types::Admin::Site, { null: true }], null: false
    end
  end
end
