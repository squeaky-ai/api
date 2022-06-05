# frozen_string_literal: true

module Mutations
  module Events
    class AddToGroup < SiteMutation
      null true

      graphql_name 'EventAddToGroup'

      argument :site_id, ID, required: true
      argument :group_id, ID, required: true
      argument :event_ids, [ID], required: true

      type [Types::Events::CaptureItem]

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(group_id:, event_ids:, **_rest)
        group = @site.event_groups.find(group_id)
        events = @site.event_captures.where(id: event_ids)

        events.each do |event|
          event.event_groups << group
          event.save
        end

        events
      end
    end
  end
end
