# frozen_string_literal: true

module Types
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
      x = context[:current_user].sites.find { |s| s.id == id.to_i }
      puts '@@@', x.owner_name
      x
    end

    def sites
      context[:current_user].sites
    end
  end
end
