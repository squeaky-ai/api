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

    field :site_session_settings, Types::Sites::SessionSettings, null: true do
      argument :site_id, String, required: true
    end

    field :sites, [Types::Sites::Site, { null: true }], null: false

    field :user_invitation, Types::Users::Invitation, null: true do
      argument :token, String, required: true
    end

    field :plans, [Types::Plans::Plan, { null: false }], null: false

    field :feedback, Types::Feedback::Feedback, null: true do
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
      SiteService.find_by_id(context[:current_user], site_id)
    end

    def site_by_uuid(site_id:)
      SiteService.find_by_uuid(context[:current_user], site_id)
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

    def site_session_settings(arguments)
      site = Site.new(uuid: arguments[:site_id])
      DataCacheService::Sites::Settings.new(site:).call
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

      posts = posts.order('created_at DESC')

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
