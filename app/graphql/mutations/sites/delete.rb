# frozen_string_literal: true

module Mutations
  module Sites
    class Delete < SiteMutation
      null true

      graphql_name 'SitesDelete'

      argument :site_id, ID, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER]
      end

      def resolve_with_timings
        fire_squeaky_event

        # Send an email to everyone in the team besides the owner
        site.team.each { |t| SiteMailer.destroyed(t, site).deliver_now }
        # Send an email to us so we have a record of it
        AdminMailer.site_destroyed(site).deliver_now
        site.destroy_all_recordings!
        site.destroy!

        nil
      end

      private

      def fire_squeaky_event
        EventTrackingJob.perform_later(
          name: 'SiteDeleted',
          user_id: user.id,
          data: {
            name: site.name,
            created_at: site.created_at.iso8601,
            provider: site.provider
          }
        )
      end
    end
  end
end
