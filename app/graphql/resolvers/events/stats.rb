# frozen_string_literal: true

module Resolvers
  module Events
    class Stats < Resolvers::Base
      type [Types::Events::Stat, { null: true }], null: false

      argument :group_ids, [ID], required: true, default_value: []
      argument :capture_ids, [ID], required: true, default_value: []
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(group_ids:, capture_ids:, from_date:, to_date:)
        site = Site.find(object.id)
        # Get a list of all the capture events including ones
        # that are included inside groups. This will be flattened
        # list where all the grouped captures appear along side the
        # actual captures
        capture_events = event_captures(site, group_ids, capture_ids)

        return [] if capture_events.empty?

        # Perform a chungus union query to get back all the results in
        # a single request
        results = aggregated_results(site, capture_events, from_date, to_date)
        # Format the events so that they use the correct keys for
        # the response including the the visitor counts
        capture_events_with_counts = format_capture_events(results)
        # The user requested groups and events so we need to
        # aggregate the results back. This will require combining
        # the counts for those that should appear in groups
        aggregate_results(site, capture_events_with_counts, group_ids, capture_ids)
      end

      private

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
        ids = Sql.execute(sql, [group_ids]).map { |id| id['event_capture_id'] }

        # Someone may have selected a capture that is
        # in a group so they should be flattened
        [capture_ids, ids].flatten.map(&:to_i).uniq
      end

      def event_captures(site, group_ids, capture_ids)
        # Get a list of all the capture ids including
        # those that need to be expanded from their
        # groups
        capture_ids = all_event_ids(group_ids, capture_ids)
        # Fetch all the corrosponding groups from the
        # site
        site.event_captures.where(id: capture_ids)
      end

      def aggregated_results(site, capture_events, from_date, to_date)
        union_queries = capture_events.map.with_index do |event, index|
          query = EventsService::Captures.for(event).count

          "(#{query})#{index == capture_events.size - 1 ? '' : ' UNION ALL '}"
        end

        # Wrap the union queries in another query that peforms
        # the limiting, sorting etc
        sql = <<-SQL
          SELECT results.event_id event_id, results.count count, results.event_name
          FROM (#{union_queries.join(' ')}) results
        SQL

        query = ActiveRecord::Base.sanitize_sql_array(
          [sql, { site_id: site.id, from_date:, to_date: }]
        )

        ClickHouse.connection.select_all(query)
      end

      def format_capture_events(results)
        visitor_count = total_visitors_count

        results.map do |result|
          {
            id: result['event_id'],
            name: result['event_name'],
            count: result['count'],
            average_events_per_visitor: (result['count'] / visitor_count).round(2)
          }
        end
      end

      def total_visitors_count
        sql = <<-SQL
          SELECT COUNT(DISTINCT(visitor_id))
          FROM recordings
          WHERE site_id = ?
        SQL

        Sql.execute(sql, [object.id]).first['count']
      end

      def aggregate_results(site, capture_events_with_counts, group_ids, capture_ids)
        groups = site.event_groups.where(id: group_ids).includes(:event_captures)

        [
          *capture_ids.map { |id| aggregate_capture(id, capture_events_with_counts) },
          *group_ids.map { |id| aggregate_group(id, groups, capture_events_with_counts) }
        ]
      end

      def aggregate_capture(id, capture_events_with_counts)
        capture = capture_events_with_counts.detect { |c| c[:id] == id }

        { **capture, type: 'capture' }
      end

      def aggregate_group(id, groups, capture_events_with_counts)
        # Find the group that matches this id
        group = groups.detect { |g| g.id.to_s == id }
        # Get a list of all the event capture ids for this group
        capture_ids = group.event_captures.map(&:id).map(&:to_s)
        # Get al ist of all the capture_events_with_counts that
        # are in the list of capture_ids
        captures = capture_events_with_counts.filter { |c| capture_ids.include?(c[:id]) }

        count = captures.map { |c| c[:count] }.sum
        average_events_per_visitor = captures.map { |c| c[:average_events_per_visitor] }.sum

        {
          id: group.id,
          name: group.name,
          type: 'group',
          count:,
          average_events_per_visitor:
        }
      end
    end
  end
end
