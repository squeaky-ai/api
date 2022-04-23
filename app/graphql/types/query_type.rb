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

    field :site_by_uuid, Types::Sites::Site, null: true do
      argument :site_id, ID, required: true
    end

    field :sites, [Types::Sites::Site, { null: true }], null: false

    field :user_invitation, Types::Users::Invitation, null: true do
      argument :token, String, required: true
    end

    field :plans, [Types::Plans::Plan, { null: false }], null: false

    field :feedback, Types::Feedback::Feedback, null: true do
      argument :site_id, String, required: true
    end

    field :css_selector_blacklist, [String, { null: true }], null: false do
      argument :site_id, String, required: true
    end

    field :blog_post, Types::Blog::Post, null: true do
      argument :slug, String, required: true
    end

    field :blog_posts, Types::Blog::Posts, null: false do
      argument :category, String, required: false
      argument :tags, [String], required: false, default_value: []
    end

    field :admin, Types::Admin::Admin, null: false

    def user
      user = context[:current_user]

      user&.touch :last_activity_at

      user
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

    def site_by_uuid(site_id:)
      # This is used externally for the magic erasure and
      # should not raise
      return nil unless context[:current_user]

      team = { status: Team::ACCEPTED }
      context[:current_user].sites.find_by(uuid: site_id, team:)
    end

    def sites
      raise Errors::Unauthorized unless context[:current_user]

      # We don't show pending sites to the user in the UI
      team = { status: Team::ACCEPTED }
      context[:current_user].sites.where(team:).includes(%i[teams users])
    end

    def user_invitation(token:)
      User.find_team_invitation(token)
    end

    def plans
      ::Plans.to_a
    end

    def feedback(arguments)
      Site.find_by(uuid: arguments[:site_id])&.feedback
    end

    def css_selector_blacklist(arguments)
      Site.find_by(uuid: arguments[:site_id])&.css_selector_blacklist || []
    end

    def blog_post(arguments)
      blog = ::Blog.find_by_slug(arguments[:slug])

      return nil if blog&.draft && !context[:current_user]&.superuser?

      blog
    end

    def blog_posts(arguments)
      posts = context[:current_user]&.superuser? ? ::Blog.all : ::Blog.where(draft: false)

      posts = posts.where('LOWER(category) = ?', arguments[:category].downcase) if arguments[:category]
      posts = posts.where('tags && ARRAY[?]::varchar[]', arguments[:tags]) unless arguments[:tags].empty?

      {
        posts:,
        tags: ::Blog.tags,
        categories: ::Blog.categories
      }
    end

    def admin
      raise Errors::Unauthorized unless context[:current_user]&.superuser?

      {}
    end
  end
end
