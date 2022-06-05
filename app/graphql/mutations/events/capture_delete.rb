# frozen_string_literal: true

module Mutations
  module Events
    class CaptureDelete < SiteMutation
      null true

      graphql_name 'EventCaptureDelete'

      argument :site_id, ID, required: true
      argument :event_id, ID, required: true

      type Types::Events::CaptureItem

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(event_id:, **_rest)
        event = @site.event_captures.find_by(id: event_id)

        event&.destroy

        nil
      end
    end
  end
end
