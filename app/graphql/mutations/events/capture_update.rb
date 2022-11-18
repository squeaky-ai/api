# frozen_string_literal: true

module Mutations
  module Events
    class CaptureUpdate < SiteMutation
      null true

      graphql_name 'EventCaptureUpdate'

      argument :site_id, ID, required: true
      argument :event_id, ID, required: true
      argument :name, String, required: true
      argument :rules, [Types::Events::RuleInput], required: true
      argument :group_ids, [Int], required: true

      type Types::Events::CaptureItem

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(event_id:, name:, rules:, group_ids:, **_rest)
        event = @site.event_captures.find_by(id: event_id)

        return nil unless event

        groups = EventGroup.where(id: group_ids, site_id: @site.id)

        # Update what can be updated, and then reset the count
        # and last_counted_at as the rules may have changed
        event.update(
          name:,
          rules:,
          event_groups: groups,
          count: 0,
          last_counted_at: nil
        )

        # Kick the job off to update when we've changed it to make
        # sure the updates are reflected quickly
        EventsProcessingJob.perform_later([event.id])

        event
      end
    end
  end
end
