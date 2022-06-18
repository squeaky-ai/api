# frozen_string_literal: true

module Resolvers
  module Events
    class Counts < Resolvers::Base
      type Types::Events::Counts, null: false

      argument :group_ids, [ID], required: true, default_value: []
      argument :capture_ids, [ID], required: true, default_value: []
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve(group_ids:, capture_ids:, from_date:, to_date:)
        site = Site.find(object.id)

        date_format, group_type, group_range = Charts.date_groups(from_date, to_date, clickhouse: true)

        capture_events = event_captures(site, group_ids, capture_ids)
        results = aggregated_results(site, capture_events, from_date, to_date, date_format)

        {
          group_type:,
          group_range:,
          items: aggregate_results(site, results, group_ids, capture_ids)
        }
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

      def union_queries(capture_events)
        @union_queries ||= capture_events.map.with_index do |event, index|
          query = EventsService::Captures.for(event).counts

          "#{query}#{index == capture_events.size - 1 ? '' : ' UNION ALL '}"
        end
      end

      def aggregated_results(site, capture_events, from_date, to_date, date_format)
        sql = <<-SQL
          SELECT results.*
          FROM (#{union_queries(capture_events).join(' ')}) results
          FORMAT JSON
        SQL

        query = ActiveRecord::Base.sanitize_sql_array(
          [
            sql,
            { site_id: site.id, from_date:, to_date:, date_format: }
          ]
        )

        ClickHouse.connection.select_all(query)
      end

      def aggregate_results(site, results, group_ids, capture_ids)
        groups = site.event_groups.where(id: group_ids).includes(:event_captures)

        results_captures = results.filter { |r| capture_ids.include?(r['id']) }

        [
          # These ones are easy as we already know that they were
          # specifically requested as capture_ids, and have been
          # filtered. All we need to do is add the  type and return them.
          *results_captures.map { |capture| aggregate_capture(capture) },
          # These are more difficult as we need group them all by the
          # group id and by the date_key.
          *aggregate_groups(results, groups)
        ]
      end

      def aggregate_capture(capture)
        { **capture, type: 'capture' }
      end

      def aggregate_groups(results, groups)
        date_keys = results.map { |r| r['date_key'] }.uniq

        combined = groups.map do |group|
          capture_ids = group.event_captures.map(&:id).map(&:to_s)

          date_keys.map do |date_key|
            matches = results.filter { |r| r['date_key'] == date_key && capture_ids.include?(r['id']) }

            {
              id: group.id,
              type: 'group',
              date_key:,
              count: matches.map { |m| m['count'] }.sum
            }
          end
        end

        combined.flatten
      end
    end
  end
end
