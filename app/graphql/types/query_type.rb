# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Users
    field :user, resolver: Resolvers::Users::User
    field :user_exists, resolver: Resolvers::Users::UserExists
    field :user_invitation, resolver: Resolvers::Users::UserInvitation

    # Sites
    field :site, resolver: Resolvers::Sites::Site
    field :site_by_uuid, resolver: Resolvers::Sites::SiteByUuid
    field :site_session_settings, resolver: Resolvers::Sites::SiteSessionSettings
    field :sites, resolver: Resolvers::Sites::Sites

    # Public
    field :plans, resolver: Resolvers::Sites::Plans
    field :partner, resolver: Resolvers::Partners::Partner

    # Blog
    field :blog_post, resolver: Resolvers::Blog::Post
    field :blog_posts, resolver: Resolvers::Blog::Posts

    # Changelog
    field :changelog_post, resolver: Resolvers::Changelog::Post
    field :changelog_posts, resolver: Resolvers::Changelog::Posts

    # Admin
    field :admin, resolver: Resolvers::Admin::Admin
  end
end
