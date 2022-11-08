# frozen_string_literal: true

module Mutations
  module Sites
    class Create < UserMutation
      null false

      graphql_name 'SitesCreate'

      argument :name, String, required: true
      argument :url, String, required: true
      argument :site_type, Integer, required: false

      type Types::Sites::Site

      def resolve(name:, url:, site_type: Site::WEBSITE)
        site = Site.create(
          name:,
          site_type:,
          url: uri(url)
        )

        raise GraphQL::ExecutionError, site.errors.full_messages.first unless site.valid?

        # Set the current user as the admin of the site
        # and skip the confirmation steps
        Team.create(status: Team::ACCEPTED, role: Team::OWNER, user: @user, site:)

        # Update the referral if it exists
        Referral.find_by_url(site.url)&.update(site:)

        site.reload
      end

      private

      def uri(url)
        formatted_uri = Site.format_uri(url)
        # This is quite important! The last thing we want
        # is nil://nil being in there and being unique!
        raise Exceptions::SiteInvalidUri unless formatted_uri

        formatted_uri
      end
    end
  end
end
