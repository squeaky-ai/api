# frozen_string_literal: true

module Resolvers
  module Events
    class Stats < Resolvers::Base
      type [Types::Events::Stat, { null: false }], null: false

      argument :group_ids, [ID], required: true, default_value: []
      argument :capture_ids, [ID], required: true, default_value: []
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(group_ids:, capture_ids:, from_date:, to_date:)
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        # Get a list of all the capture events including ones
        # that are included inside groups. This will be flattened
        # list where all the grouped captures appear along side the
        # actual captures
        capture_events = event_captures(group_ids, capture_ids)

        return [] if capture_events.empty?

        # Perform a chungus union query to get back all the results in
        # a single request
        results = aggregated_results(capture_events, range)
        # Format the events so that they use the correct keys for
        # the response including the the visitor counts
        capture_events_with_counts = format_capture_events(results)
        # The user requested groups and events so we need to
        # aggregate the results back. This will require combining
        # the counts for those that should appear in groups
        aggregate_results(capture_events_with_counts, group_ids, capture_ids)
      end

      private

      def all_event_ids(group_ids, capture_ids)
        sql = <<-SQL.squish
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

      def aggregated_results(capture_events, range)
        union_queries = capture_events.map.with_index do |event, index|
          query = EventsService::Captures.for(event).count

          "(#{query})#{index == capture_events.size - 1 ? '' : ' UNION ALL '}"
        end

        # Wrap the union queries in another query that peforms
        # the limiting, sorting etc
        sql = <<-SQL.squish
          SELECT
            results.event_id event_id,
            results.unique_triggers,
            results.count count,
            results.event_name,
            results.recording_ids
          FROM (#{union_queries.join(' ')}) results
        SQL

        variables = {
          site_id: object.id,
          timezone: range.timezone,
          from_date: "#{range.from} 00:00:00",
          to_date: "#{range.to} 23:59:59"
        }

        Sql::ClickHouse.select_all(sql, variables)
      end

      def format_capture_events(results)
        results.map do |result|
          # This is n+1 but should be fast enough
          recording_stats = fetch_recordings_stats(result['recording_ids'].uniq)

          {
            id: result['event_id'],
            name: result['event_name'],
            count: result['count'],
            average_events_per_visitor: result['count'].to_f / result['unique_triggers'],
            unique_triggers: result['unique_triggers'],
            average_session_duration: recording_stats['average_session_duration'],
            browsers: recording_stats['browsers'],
            referrers: recording_stats['referrers']
          }
        end
      end

      def aggregate_results(capture_events_with_counts, group_ids, capture_ids)
        groups = object.event_groups.where(id: group_ids).includes(:event_captures)

        [
          *capture_ids.map { |id| aggregate_capture(id, capture_events_with_counts) },
          *group_ids.map { |id| aggregate_group(id, groups, capture_events_with_counts) }
        ]
      end

      def aggregate_capture(id, capture_events_with_counts)
        capture = capture_events_with_counts.detect { |c| c[:id] == id }

        {
          event_or_group_id: capture[:id],
          name: capture[:name],
          count: capture[:count],
          type: 'capture',
          average_events_per_visitor: capture[:average_events_per_visitor],
          unique_triggers: capture[:unique_triggers],
          average_session_duration: capture[:average_session_duration],
          browsers: to_string_record(capture[:browsers].tally),
          referrers: to_string_record(capture[:referrers].tally)
        }
      end

      def aggregate_group(id, groups, capture_events_with_counts)
        # Find the group that matches this id
        group = groups.detect { |g| g.id.to_s == id }
        # Get a list of all the event capture ids for this group
        capture_ids = group.event_captures.map(&:id).map(&:to_s)
        # Get a list of all the capture_events_with_counts that
        # are in the list of capture_ids
        captures = capture_events_with_counts.filter { |c| capture_ids.include?(c[:id]) }

        count = captures.pluck(:count).sum
        unique_triggers = captures.pluck(:unique_triggers).sum
        average_events_per_visitor = Maths.average(captures.pluck(:average_events_per_visitor))
        average_session_duration = Maths.average(captures.pluck(:average_session_duration))
        browsers = to_string_record(captures.pluck(:browsers).flatten.tally)
        referrers = to_string_record(captures.pluck(:referrers).flatten.tally)

        {
          event_or_group_id: group.id,
          name: group.name,
          type: 'group',
          count:,
          average_events_per_visitor:,
          unique_triggers:,
          average_session_duration:,
          browsers:,
          referrers:
        }
      end

      def fetch_recordings_stats(recording_ids)
        sql = <<-SQL.squish
          SELECT
            AVG(activity_duration) average_session_duration,
            groupArray(browser) browsers,
            groupArray(referrer) referrers
          FROM
            recordings
          WHERE
            site_id = :site_id AND
            recording_id IN (:recording_ids)
        SQL

        variables = {
          site_id: object.id,
          recording_ids:
        }

        Sql::ClickHouse.select_one(sql, variables)
      end

      def to_string_record(tally)
        tally.map do |key, value|
          {
            key:,
            value:
          }
        end
      end
    end
  end
end
