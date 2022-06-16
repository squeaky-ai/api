# frozen_string_literal: true

module Resolvers
  module Events
    class Feed < Resolvers::Base
      type Types::Events::Feed, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 20
      argument :sort, Types::Events::FeedSort, required: false, default_value: 'timestamp__desc'
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true
      argument :group_ids, [ID], required: true
      argument :capture_ids, [ID], required: true

      def resolve(page:, size:, sort:, from_date:, to_date:, group_ids:, capture_ids:)
        site = Site.find(object.id)

        capture_events = event_captures(site, group_ids, capture_ids)
        results = aggregated_results(site, capture_events, from_date, to_date, page, size, sort)
        recordings = recordings(site, results)

        {
          items: format_results(results, recordings),
          pagination: {
            page_size: size,
            total: results.size, # TODO: fetch true count
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

      def format_results(results, recordings)
        results.map do |result|
          recording = recordings.detect { |r| r.id == result['recording_id'] }

          {
            id: result['uuid'],
            event_name: result['event_name'],
            timestamp: result['timestamp'],
            recording:,
            visitor: recording.visitor
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

      def event_captures(site, group_ids, capture_ids)
        # Get a list of all the capture ids including
        # those that need to be expanded from their
        # groups
        capture_ids = all_event_ids(group_ids, capture_ids)
        # Fetch all the corrosponding groups from the
        # site
        site.event_captures.where(id: capture_ids)
      end

      def aggregated_results(site, capture_events, from_date, to_date, page, size, sort)
        union_queries = capture_events.map.with_index do |event, index|
          query = EventsService::Captures.for(event).results

          # TODO: Invesigate how we can limit here as otherwise it
          # will return them all

          # Build a big MF union query of all the queries
          # that come from the EventService. Each query
          # needs to be followed by a UNION ALL so they get
          # aggregated, apart from the last index
          "(#{query})#{index == capture_events.size - 1 ? '' : ' UNION ALL '}"
        end

        # Wrap the union queries in another query that peforms
        # the limiting, sorting etc
        sql = <<-SQL
          SELECT
            results.uuid uuid,
            results.recording_id recording_id,
            results.event_name event_name,
            toDateTime(results.timestamp / 1000) timestamp
          FROM (#{union_queries.join(' ')}) results
          ORDER BY #{order(sort)}
          LIMIT :limit
          OFFSET :offset
        SQL

        query = ActiveRecord::Base.sanitize_sql_array(
          [
            sql,
            { site_id: site.id, limit: size, offset: (size * (page - 1)), from_date:, to_date: }
          ]
        )

        ClickHouse.connection.select_all(query)
      end

      def recordings(site, results)
        ids = results.map { |r| r['recording_id'] }.uniq

        site
          .recordings
          .where(id: ids)
          .includes(:visitor)
      end
    end
  end
end
