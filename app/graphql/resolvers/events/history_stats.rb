# frozen_string_literal: true

module Resolvers
  module Events
    class HistoryStats < Resolvers::Base
      type [Types::Events::HistoryStat, { null: true }], null: false

      argument :group_ids, [ID], required: true, default_value: []
      argument :capture_ids, [ID], required: true, default_value: []

      def resolve(group_ids:, capture_ids:)
        site = Site.find(object.id)

        groups = site.event_groups.where(id: group_ids)
        events = site.event_captures.where(id: capture_ids)

        [
          *groups.map { |g| format_item(g, 'group') },
          *events.map { |e| format_item(e, 'capture') }
        ]
      end

      private

      def format_item(group_or_capture, type)
        {
          id: group_or_capture.id,
          name: group_or_capture.name,
          type:,
          count: group_or_capture.count,
          average_events_per_visitor: 0
        }
      end
    end
  end
end
