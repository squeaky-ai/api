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

    field :sites_admin, [Types::Sites::Site, { null: true }], null: false

    field :users_admin, [Types::Users::User, { null: true }], null: false

    field :active_users_admin, Integer, null: false

    field :user_invitation, Types::Users::Invitation, null: true do
      argument :token, String, required: true
    end

    field :plans, [Types::Plans::Plan, { null: false }], null: false

    field :feedback, Types::Feedback::Feedback, null: true do
      argument :site_id, String, required: true
    end

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

      # We don't show pending sites to the user in the UI
      team = { status: Team::ACCEPTED }
      context[:current_user].sites.where(team:).includes(%i[teams users])
    end

    def sites_admin
      raise Errors::Unauthorized unless context[:current_user]&.superuser?

      Site.includes(%i[teams users]).all
    end

    def users_admin
      raise Errors::Unauthorized unless context[:current_user]&.superuser?

      User.all
    end

    def active_users_admin
      raise Errors::Unauthorized unless context[:current_user]&.superuser?

      keys = Redis.current.keys('active_user_count:*')
      keys.inject(0) { |sum, key| sum + Redis.current.get(key).to_i }
    end

    def user_invitation(token:)
      User.find_team_invitation(token)
    end

    def plans
      Plan.to_a
    end

    def feedback(arguments)
      Site.find_by(uuid: arguments[:site_id])&.feedback
    end
  end
end
