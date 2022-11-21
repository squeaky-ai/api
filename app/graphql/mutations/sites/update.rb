# frozen_string_literal: true

module Mutations
  module Sites
    class Update < SiteMutation
      null false

      graphql_name 'SitesUpdate'

      argument :site_id, ID, required: true
      argument :name, String, required: false
      argument :url, String, required: false
      argument :site_type, Integer, required: false

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(name: nil, url: nil, site_type: nil) # rubocop:disable Metrics/AbcSize
        update = {}
        update[:name] = name if name
        update[:site_type] = site_type if site_type

        if url
          update[:url] = uri(url)
          # Reset the verification if the url changes as
          # it could be incorrect
          update[:verified_at] = nil
        end

        site.update(update)

        raise GraphQL::ExecutionError, site.errors.full_messages.first unless site.valid?

        SiteService.delete_cache(user, site.id)

        site
      end

      private

      def uri(url)
        raise Exceptions::SiteInvalidUri if url.include?('localhost')

        formatted_uri = Site.format_uri(url)
        # This is quite important! The last thing we want
        # is nil://nil being in there and being unique!
        raise Exceptions::SiteInvalidUri unless formatted_uri

        formatted_uri
      end
    end
  end
end
