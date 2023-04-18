# frozen_string_literal: true

module Mutations
  module Events
    class CaptureCreate < SiteMutation
      null false

      graphql_name 'EventCaptureCreate'

      argument :site_id, ID, required: true
      argument :type, Int, required: true
      argument :name, String, required: true
      argument :rules, [Types::Events::RuleInput], required: true
      argument :group_ids, [Int], required: true

      type Types::Events::CaptureItem

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(type:, name:, rules:, group_ids:)
        groups = EventGroup.where(id: group_ids, site_id: site.id)

        event = EventCapture.create(
          name:,
          rules:,
          event_type: type,
          site:,
          event_groups: groups
        )

        raise GraphQL::ExecutionError, event.errors.full_messages.first unless event.valid?

        # Go off and run the job in the background to
        # fetch the history events and update the counts.
        # This can take a while depending on how old the
        # site is so we must do it in the background
        EventsProcessingJob.perform_later([event.id])

        event
      end
    end
  end
end
