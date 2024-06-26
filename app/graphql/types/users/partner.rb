# frozen_string_literal: true

module Types
  module Users
    class Partner < Types::BaseObject
      graphql_name 'UsersPartner'

      field :id, ID, null: false
      field :name, String, null: false
      field :slug, String, null: false
      field :referrals, resolver: Resolvers::Users::Referrals
    end
  end
end
