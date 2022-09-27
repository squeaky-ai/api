# frozen_string_literal: true

module Types
  module Admin
    class Admin < Types::BaseObject
      graphql_name 'Admin'

      field :site, resolver: Resolvers::Admin::Site
      field :users, resolver: Resolvers::Admin::Users
      field :users_count, resolver: Resolvers::Admin::UsersCount
      field :users_stored, resolver: Resolvers::Admin::UsersStored
      field :sites, resolver: Resolvers::Admin::Sites
      field :sites_count, resolver: Resolvers::Admin::SitesCount
      field :sites_stored, resolver: Resolvers::Admin::SitesStored
      field :active_visitors, resolver: Resolvers::Admin::ActiveVisitors
      field :active_monthly_users, resolver: Resolvers::Admin::ActiveMonthlyUsers
      field :roles, resolver: Resolvers::Admin::Roles
      field :verified, resolver: Resolvers::Admin::Verified
      field :blog_images, resolver: Resolvers::Admin::BlogImages
      field :recordings_processed, resolver: Resolvers::Admin::RecordingsProcessed
      field :recordings_count, resolver: Resolvers::Admin::RecordingsCount
      field :visitors_count, resolver: Resolvers::Admin::VisitorsCount
      field :recordings_stored, resolver: Resolvers::Admin::RecordingsStored
    end
  end
end
