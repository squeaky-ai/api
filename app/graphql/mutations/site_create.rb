# frozen_string_literal: true

require 'date'

module Mutations
  # Create a new site and set the current_user as the
  # owner. The uri must be valid and also unique. Any
  # ActiveRecord errors will be raised as GraphQL errors
  class SiteCreate < UserMutation
    null false

    argument :name, String, required: true
    argument :url, String, required: true

    type Types::SiteType

    def resolve(name:, url:)
      site = Site.create(name: name, url: uri(url), plan: Site::ESSENTIALS)

      raise GraphQL::ExecutionError, site.errors.full_messages.first unless site.valid?

      # Set the current user as the admin of the site
      # and skip the confirmation steps
      Team.create(status: Team::ACCEPTED, role: Team::OWNER, user: @user, site: site)

      # Add the authorization details for the gateway
      # so that the lambdas can check for auth
      site.create_authorizer!

      site.reload
    end

    private

    def uri(url)
      formatted_uri = Site.format_uri(url)
      # This is quite important! The last thing we want
      # is nil://nil being in there and being unique!
      raise Errors::SiteInvalidUri unless formatted_uri

      formatted_uri
    end
  end
end
