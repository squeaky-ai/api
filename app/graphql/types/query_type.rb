# frozen_string_literal: true

module Types
  # All of the queries available to the client, note
  # that any authentication is done on a per query
  # level
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :user, UserType, null: true do
      description "Get the user from the session.\nIt will return null if there is no session"
    end

    field :site, SiteType, null: true do
      description 'Get a single site'
      argument :site_id, ID, required: true
    end

    field :sites, [SiteType, { null: true }], null: false do
      description "Get a list of sites for the user.\nWarning: Loading the recordings here is n+1 and expensive!"
    end

    field :user_invitation, UserInvitationType, null: true do
      description 'Get the user from the invite token'
      argument :token, String, required: true
    end

    def user
      context[:current_user]
    end

    def site(site_id:)
      raise Errors::Unauthorized unless context[:current_user]

      # Super users don't play by the rules
      return Site.find_by(id: site_id.to_i) if context[:current_user].superuser?

      # We don't show pending sites to the user in the UI
      team = { status: Team::ACCEPTED }
      context[:current_user].sites.find_by(id: site_id.to_i, team: team)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def sites
      raise Errors::Unauthorized unless context[:current_user]

      # Show everything to superusers
      return Site.all if context[:current_user].superuser?

      # We don't show pending sites to the user in the UI
      team = { status: Team::ACCEPTED }
      context[:current_user].sites.where(team: team)
    end

    def user_invitation(token:)
      User.find_team_invitation(token)
    end
  end
end
