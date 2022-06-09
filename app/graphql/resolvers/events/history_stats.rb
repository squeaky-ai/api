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
          *groups.map { |g| format_group(g) },
          *events.map { |e| format_capture(e) }
        ]
      end

      private

      def format_group(capture)
        {
          id: capture.id,
          name: capture.name,
          type: 'group',
          count: capture.event_captures.map(&:count).sum,
          average_events_per_visitor: 0
        }
      end

      def format_capture(capture)
        {
          id: capture.id,
          name: capture.name,
          type: 'capture',
          count: capture.count,
          average_events_per_visitor: 0
        }
      end
    end
  end
end
