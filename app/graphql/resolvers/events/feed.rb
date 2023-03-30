# frozen_string_literal: true

module Resolvers
  module Events
    class Feed < Resolvers::Base # rubocop:disable Metrics/ClassLength
      type 'Types::Events::Feed', null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 20
      argument :sort, Types::Events::FeedSort, required: false, default_value: 'timestamp__desc'
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true
      argument :group_ids, [ID], required: true
      argument :capture_ids, [ID], required: true

      def resolve_with_timings(page:, size:, sort:, from_date:, to_date:, group_ids:, capture_ids:) # rubocop:disable Metrics/ParameterLists
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        capture_events = event_captures(group_ids, capture_ids)
        results = aggregated_results(capture_events, range, page, size, sort)
        results_count = total_results_count(capture_events, range)
        recordings = recordings(results)
        visitors = visitors(results)

        {
          items: format_results(results, recordings, visitors),
          pagination: {
            page_size: size,
            total: results_count,
            sort:
          }
        }
      end

      private

      def order(sort)
        sorts = {
          'timestamp__asc' => 'timestamp ASC',
          'timestamp__desc' => 'timestamp DESC'
        }
        sorts[sort]
      end

      def format_results(results, recordings, visitors)
        results.map do |result|
          recording = recordings.detect { |r| r.id == result['recording_id'] }
          visitor = visitors.detect { |v| v.id == result['visitor_id'] }

          {
            id: result['uuid'],
            event_name: result['event_name'],
            timestamp: result['timestamp'],
            source: result['source'],
            data: result['data'],
            recording:,
            # Custom events from the API will not have
            # a recording so the visitor must be fetched
            # by the visitor id
            visitor: recording&.visitor || visitor
          }
        end
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
        ids = Sql.execute(sql, [group_ids]).map { |id| id['event_capture_id'] }

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
          query = EventsService::Captures.for(event).results
          # Build a big MF union query of all the queries
          # that come from the EventService. Each query
          # needs to be followed by a UNION ALL so they get
          # aggregated, apart from the last index
          "(#{query})#{index == capture_events.size - 1 ? '' : ' UNION ALL '}"
        end
      end

      def total_results_count(capture_events, range)
        sql = <<-SQL
          SELECT COUNT(*) count
          FROM (#{union_queries(capture_events).join(' ')})
        SQL

        variables = {
          site_id: object.id,
          from_date: range.from,
          to_date: range.to,
          timezone: range.timezone
        }

        Sql::ClickHouse.select_value(sql, variables)
      end

      def aggregated_results(capture_events, range, page, size, sort)
        # Wrap the union queries in another query that peforms
        # the limiting, sorting etc
        sql = <<-SQL
          SELECT
            results.uuid uuid,
            results.recording_id recording_id,
            results.event_name event_name,
            results.source source,
            results.data data,
            results.visitor_id visitor_id,
            toDateTime(results.timestamp / 1000, :timezone) timestamp
          FROM (#{union_queries(capture_events).join(' ')}) results
          ORDER BY #{order(sort)}
          LIMIT :limit
          OFFSET :offset
        SQL

        variables = {
          site_id: object.id,
          limit: size,
          offset: (size * (page - 1)),
          timezone: range.timezone,
          from_date: range.from,
          to_date: range.to
        }

        Sql::ClickHouse.select_all(sql, variables)
      end

      def recordings(results)
        ids = results.map { |r| r['recording_id'] }.uniq

        object
          .recordings
          .where(id: ids)
          .includes(:visitor)
      end

      def visitors(results)
        # Only custom events from the api will need to look
        # visitors up this way as they are the only ones that
        # do not have a recording
        ids = results
              .select { |r| r['source'] == EventCapture::API }
              .map { |r| r['visitor_id'] }
              .reject(&:zero?)
              .uniq

        object
          .visitors
          .where(id: ids)
      end
    end
  end
end
