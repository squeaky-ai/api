# frozen_string_literal: true

module Resolvers
  module Recordings
    class Events < Resolvers::Base
      type Types::Recordings::Events, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 250

      def resolve_with_timings(page:, size:)
        events = list_events_from_s3(page)
        if events
          Rails.logger.info('Playing back events using S3')
          return events
        end

        list_events_from_postgres(page, size)
      end

      private

      # S3 related stuff

      def list_events_from_s3(page)
        files = list_files_in_s3

        return if files.empty?

        {
          items: get_events_file(files[page - 1]),
          pagination: s3_pagination(files)
        }
      end

      def list_files_in_s3
        client = Aws::S3::Client.new
        prefix = "#{object.site.uuid}/#{object.visitor.visitor_id}/#{object.session_id}"

        files = client.list_objects_v2(prefix:, bucket: 'events.squeaky.ai')
        files.contents.map { |c| c[:key] }.filter { |c| c.end_with?('.json') }
      end

      def get_events_file(key)
        client = Aws::S3::Client.new
        file = client.get_object(key:, bucket: 'events.squeaky.ai')

        JSON.parse(file.body.read)
      end

      def s3_pagination(files)
        {
          per_page: -1,
          item_count: -1,
          current_page: arguments[:page],
          total_pages: files.size
        }
      end

      # Postgres stuff

      def list_events_from_postgres(page, size)
        results = events(page, size)
        results_total = total_count

        {
          items: results,
          pagination: pagination(results_total)
        }
      end

      def events(page, size)
        sql = <<-SQL
          SELECT id, data, event_type as type, timestamp
          FROM events
          WHERE recording_id = ?
          ORDER BY timestamp ASC
          OFFSET ?
          LIMIT ?
        SQL

        Sql.execute(sql, [object.id, size * (page - 1), size])
      end

      def total_count
        sql = <<-SQL
          SELECT COUNT(*)
          FROM events
          WHERE recording_id = ?
        SQL

        Sql.execute(sql, [object.id]).first['count']
      end

      def pagination(results_total)
        {
          per_page: arguments[:size],
          item_count: results_total,
          current_page: arguments[:page],
          total_pages: (results_total.to_f / arguments[:size]).ceil
        }
      end
    end
  end
end
