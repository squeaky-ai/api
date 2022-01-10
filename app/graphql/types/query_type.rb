# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :user, Types::Users::User, null: true

    field :user_exists, Boolean, null: false do
      argument :email, String, required: true
    end

    field :site, Types::Sites::Site, null: true do
      argument :site_id, ID, required: true
    end

    field :sites, [Types::Sites::Site, { null: true }], null: false

    field :user_invitation, Types::Users::Invitation, null: true do
      argument :token, String, required: true
    end

    field :plans, [Types::Plans::Plan, { null: false }], null: false

    def user
      context[:current_user]
    end

    def user_exists(email:)
      User.exists?(email:)
    end

    def site(site_id:)
      raise Errors::Unauthorized unless context[:current_user]

      # Super users don't play by the rules
      return Site.includes(%i[teams users]).find_by(id: site_id) if context[:current_user].superuser?

      # We don't show pending sites to the user in the UI
      team = { status: Team::ACCEPTED }
      context[:current_user].sites.includes(%i[teams users]).find_by(id: site_id, team:)
    end

    def sites
      raise Errors::Unauthorized unless context[:current_user]

      # Show everything to superusers
      return Site.all.includes(%i[teams users]) if context[:current_user].superuser?

      # We don't show pending sites to the user in the UI
      team = { status: Team::ACCEPTED }
      context[:current_user].sites.where(team:).includes(%i[teams users])
    end

    def user_invitation(token:)
      User.find_team_invitation(token)
    end

    def plans
      Plan.to_a
    end
  end
end
