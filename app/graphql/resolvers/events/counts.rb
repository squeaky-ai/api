# frozen_string_literal: true

module Resolvers
  module Events
    class Counts < Resolvers::Base
      type Types::Events::Counts, null: false

      argument :group_ids, [ID], required: true, default_value: []
      argument :capture_ids, [ID], required: true, default_value: []
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(group_ids:, capture_ids:, from_date:, to_date:)
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        date_format, group_type, group_range = Charts.date_groups(range.from, range.to, clickhouse: true)

        capture_events = event_captures(group_ids, capture_ids)

        # The code below craps itself if there are no events
        # so return early
        return respond(group_type, group_range, []) if capture_events.empty?

        results = aggregated_results(capture_events, range, date_format)

        respond(group_type, group_range, aggregate_results(results, group_ids, capture_ids))
      end

      private

      def respond(group_type, group_range, items)
        {
          group_type:,
          group_range:,
          items:
        }
      end

      def all_event_ids(group_ids, capture_ids)
        sql = <<-SQL
          SELECT event_capture_id
          FROM event_captures_groups
          WHERE event_group_id
          IN (?)
        SQL

        # This is the much cheaper way of fetching the
        # capture ids from the group ids as there are
        # no joins necessary
        ids = Sql.execute(sql, [group_ids]).pluck('event_capture_id')

        # Someone may have selected a capture that is
        # in a group so they should be flattened
        [capture_ids, ids].flatten.map(&:to_i).uniq
      end

      def event_captures(group_ids, capture_ids)
        # Get a list of all the capture ids including
        # those that need to be expanded from their
        # groups
        capture_ids = all_event_ids(group_ids, capture_ids)
        # Fetch all the corrosponding groups from the
        # site
        object.event_captures.where(id: capture_ids)
      end

      def union_queries(capture_events)
        @union_queries ||= capture_events.map.with_index do |event, index|
          query = EventsService::Captures.for(event).counts

          "#{query}#{index == capture_events.size - 1 ? '' : ' UNION ALL '}"
        end
      end

      def aggregated_results(capture_events, range, date_format)
        sql = <<-SQL
          SELECT results.*
          FROM (#{union_queries(capture_events).join(' ')}) results
          FORMAT JSON
        SQL

        variables = {
          site_id: object.id,
          from_date: range.from,
          to_date: range.to,
          timezone: range.timezone,
          date_format:
        }

        Sql::ClickHouse.select_all(sql, variables)
      end

      def aggregate_results(results, group_ids, capture_ids)
        date_keys = results.pluck('date_key').uniq
        groups = object.event_groups.where(id: group_ids).includes(:event_captures)

        date_keys.map do |date_key|
          {
            date_key:,
            metrics: metrics_for_date_key(date_key, results, groups, capture_ids)
          }
        end
      end

      def metrics_for_date_key(date_key, results, groups, capture_ids)
        # All the metrics that match the date_key
        metrics = results.filter { |r| r['date_key'] == date_key }
        # All the metrics that are specifically capture_ids. Remember
        # that at this point the list is full of individually selected
        # captures as well as the exploded groups
        captures = metrics.filter { |r| capture_ids.include?(r['id']) } # TODO: Do we need to make these uniq?

        [
          *captures.map { |c| format_capture_metric(date_key, c) },
          *groups.map { |group| aggregate_group_metrics(date_key, group, metrics) }
        ]
      end

      def format_group_metric(group)
        { **group, type: 'group' }
      end

      def format_capture_metric(date_key, capture)
        { **capture, type: 'capture', id: "#{date_key}::#{capture['id']}" }
      end

      def aggregate_group_metrics(date_key, group, metrics)
        capture_ids = group.event_captures.map(&:id).map(&:to_s)

        group_metrics = metrics.filter { |m| capture_ids.include?(m['id']) }

        format_group_metric(
          id: "#{date_key}::#{group.id}",
          count: group_metrics.pluck('count').sum
        )
      end
    end
  end
end
