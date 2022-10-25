# frozen_string_literal: true

module Types
  module Admin
    class User < Types::Users::User
      graphql_name 'AdminUser'

      field :visitor, Types::Visitors::Visitor, null: true
      field :sites, [Types::Sites::Site, { null: false }], null: false
    end
  end
end
