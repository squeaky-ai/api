# frozen_string_literal: true

module Mutations
  module Events
    class AddToGroup < SiteMutation
      null true

      graphql_name 'EventAddToGroup'

      argument :site_id, ID, required: true
      argument :group_ids, [ID], required: true
      argument :event_ids, [ID], required: true

      type [Types::Events::CaptureItem]

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(group_ids:, event_ids:, **_rest)
        groups = @site.event_groups.where(id: group_ids)
        events = @site.event_captures.where(id: event_ids)

        events.each do |event|
          event.event_groups.concat(groups)
          event.save
        end

        events
      end
    end
  end
end
