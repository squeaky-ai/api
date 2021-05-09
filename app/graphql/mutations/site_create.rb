# frozen_string_literal: true

module Mutations
  # Create a new site and set the current_user as the
  # owner. The uri must be valid and also unique. Any
  # ActiveRecord errors will be raised as GraphQL errors
  class SiteCreate < BaseMutation
    null false

    argument :name, String, required: true
    argument :url, String, required: true

    type Types::SiteType

    def resolve(name:, url:)
      user = context[:current_user]
      site = Site.create(name: name, url: uri(url), plan: 0)

      raise GraphQL::ExecutionError, site.errors.full_messages.first unless site.valid?

      # Set the current user as the admin of the site
      # and skip the confirmation steps
      Team.create(status: 0, role: 2, user: user, site: site)
      site.reload
    end

    def ready?(_args)
      raise Errors::Unauthorized unless context[:current_user]

      true
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
