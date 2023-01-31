# frozen_string_literal: true

module Resolvers
  module Visitors
    class Events < Resolvers::Base
      type 'Types::Events::Feed', null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Events::FeedSort, required: false, default_value: 'timestamp__desc'

      def resolve_with_timings(page:, size:, sort:)
        results = events(page, size, sort)
        total_count = events_counts
        recordings = recordings(results)

        {
          items: format_results(results, recordings),
          pagination: pagination(arguments, total_count, size)
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

      def events(page, size, sort)
        sql = <<-SQL
          SELECT
            uuid uuid,
            recording_id recording_id,
            name event_name,
            source source,
            data data,
            visitor_id visitor_id,
            toDateTime(timestamp / 1000) timestamp
          FROM
            custom_events
          WHERE
            site_id = ? AND
            visitor_id = ?
          ORDER BY #{order(sort)}
          LIMIT ?
          OFFSET ?
        SQL

        variables = [
          object.site_id,
          object.id,
          size,
          (size * (page - 1))
        ]

        Sql::ClickHouse.select_all(sql, variables)
      end

      def events_counts
        sql = <<-SQL
          SELECT
            COUNT(*)
          FROM
            custom_events
          WHERE
            site_id = ? AND
            visitor_id = ?
        SQL

        variables = [
          object.site_id,
          object.id
        ]

        Sql::ClickHouse.select_value(sql, variables)
      end

      def format_results(results, recordings)
        results.map do |result|
          recording = recordings.detect { |r| r.id == result['recording_id'] }

          {
            id: result['uuid'],
            event_name: result['event_name'],
            timestamp: result['timestamp'],
            source: result['source'],
            data: result['data'],
            recording:
          }
        end
      end

      def recordings(results)
        ids = results.map { |r| r['recording_id'] }.uniq

        object
          .recordings
          .where(id: ids)
      end

      def pagination(arguments, total_count, size)
        {
          page_size: size,
          total: total_count,
          sort: arguments[:sort]
        }
      end
    end
  end
end
