# frozen_string_literal: true

module Mutations
  module Events
    class CaptureDeleteBulk < SiteMutation
      null false

      graphql_name 'EventCaptureDeleteBulk'

      argument :site_id, ID, required: true
      argument :event_ids, [String], required: true

      type [Types::Events::CaptureItem]

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(event_ids:)
        events = site.event_captures.where(id: event_ids)

        return [] if events.empty?

        events.each(&:destroy)

        []
      end
    end
  end
end
