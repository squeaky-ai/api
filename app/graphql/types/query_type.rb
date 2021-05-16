# frozen_string_literal: true

module Types
  # All of the queries available to the client, note
  # that any authentication is done on a per query
  # level
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :user, UserType, null: true do
      description "Get the user from the Bearer token.\nIt will return null if there is no session"
    end

    field :site, SiteType, null: true do
      description 'Get a single site'
      argument :id, ID, required: true
    end

    field :sites, [SiteType, { null: true }], null: false do
      description "Get a list of sites for the user.\nWarning: Loading the recordings here is n+1 and expensive!"
    end

    def user
      context[:current_user]
    end

    def site(id:)
      raise Errors::Unauthorized unless context[:current_user]

      context[:current_user].sites.find(id.to_i)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def sites
      raise Errors::Unauthorized unless context[:current_user]

      context[:current_user].sites
    end
  end
end
