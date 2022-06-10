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

        visitors_count = total_visitors_count

        [
          *groups.map { |g| format_group(g, visitors_count) },
          *events.map { |e| format_capture(e, visitors_count) }
        ]
      end

      private

      def total_visitors_count
        sql = <<-SQL
          SELECT COUNT(DISTINCT(visitor_id))
          FROM recordings
          WHERE site_id = ?
        SQL

        Sql.execute(sql, [object.id]).first['count']
      end

      def format_group(capture, visitor_count)
        count = capture.event_captures.map(&:count).sum

        {
          id: capture.id,
          name: capture.name,
          type: 'group',
          count:,
          average_events_per_visitor: (count / visitor_count).round(2)
        }
      end

      def format_capture(capture, visitor_count)
        {
          id: capture.id,
          name: capture.name,
          type: 'capture',
          count: capture.count,
          average_events_per_visitor: (capture.count / visitor_count).round(2)
        }
      end
    end
  end
end
