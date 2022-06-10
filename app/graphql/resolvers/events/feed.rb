# frozen_string_literal: true

module Resolvers
  module Events
    class Feed < Resolvers::Base
      type Types::Events::Feed, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 20
      argument :sort, Types::Events::FeedSort, required: false, default_value: 'timestamp__desc'
      argument :group_ids, [ID], required: true
      argument :capture_ids, [ID], required: true

      def resolve(page:, size:, sort:, group_ids:, capture_ids:)
        site = Site.find(object.id)

        capture_events = event_captures(site, group_ids, capture_ids)
        results = aggregated_results(site, capture_events, page, size, sort)
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
            timestamp: Time.at(result['timestamp'] / 1000).utc,
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

        ids = Sql.execute(sql, [group_ids]).map { |id| id['event_capture_id'] }

        [capture_ids, ids].flatten.map(&:to_i).uniq
      end

      def event_captures(site, group_ids, capture_ids)
        capture_ids = all_event_ids(group_ids, capture_ids)
        site.event_captures.where(id: capture_ids)
      end

      def aggregated_results(site, capture_events, page, size, sort)
        union_queries = capture_events.map.with_index do |event, index|
          query = EventsService::Captures.for(event).results

          "(#{query})#{index == capture_events.size - 1 ? '' : ' UNION ALL '}"
        end

        sql = <<-SQL
          SELECT results.uuid, results.recording_id, results.event_name, results.timestamp
          FROM (#{union_queries.join(' ')}) results
          ORDER BY #{order(sort)}
          LIMIT :limit
          OFFSET :offset
        SQL

        query = ActiveRecord::Base.sanitize_sql_array([sql, { site_id: site.id, limit: size, offset: (size * (page - 1)) }])

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
