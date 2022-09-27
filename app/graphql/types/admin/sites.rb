# frozen_string_literal: true

module Types
  module Admin
    class Sites < Types::BaseObject
      graphql_name 'AdminSites'

      field :items, [Types::Admin::Site, { null: true }], null: false
      field :pagination, Types::Admin::SitePagination, null: false
    end
  end
end
