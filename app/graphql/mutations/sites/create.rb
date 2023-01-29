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

      def resolve_with_timings(name:, url:, site_type: Site::WEBSITE)
        site = Site.create(
          name:,
          site_type:,
          url: uri(url)
        )

        raise GraphQL::ExecutionError, site.errors.full_messages.first unless site.valid?

        # Set the current user as the admin of the site
        # and skip the confirmation steps
        Team.create!(
          status: Team::ACCEPTED,
          role: Team::OWNER,
          user:,
          site:,
          linked_data_visible: true
        )

        # Update the referral if it exists
        Referral.find_by_url(site.url)&.update(site:)

        fire_squeaky_event(site)

        site.reload
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

      def fire_squeaky_event(site)
        EventTrackingJob.perform_later(
          name: 'SiteCreated',
          user_id: user.id,
          data: {
            name: site.name,
            created_at: site.created_at.iso8601
          }
        )
      end
    end
  end
end
