# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :user, UserType, null: true do
      description 'Get the user from the Bearer token'
    end

    field :site, SiteType, null: true do
      description 'Get a single site'
      argument :id, ID, required: true
    end

    field :sites, [SiteType, { null: true }], null: false do
      description 'Get a list of sites for the user'
    end

    def user
      context[:current_user]
    end

    def site(id:)
      context[:current_user].sites.find { |s| s.id == id.to_i }
    end

    def sites
      context[:current_user].sites
    end
  end
end
