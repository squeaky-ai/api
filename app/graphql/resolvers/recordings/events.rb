# frozen_string_literal: true

module Resolvers
  module Recordings
    class Events < Resolvers::Base
      type Types::Recordings::Events, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 250

      def resolve(page:, size:)
        if Rails.configuration.sites_that_store_events_in_s3.include?(object.site_id)
          events = list_events_from_s3(page)
          return events if events

          Stats.count('events_fallback_to_database')
        end

        list_events_from_database(page, size)
      end

      private

      def list_events_from_s3(page)
        files = list_files_in_s3

        return nil if files.empty?

        # If there is nothing in there then fall through as it
        # was likely stored in the database
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

        JSON.parse(file.body.read).map(&:to_json)
      end

      def s3_pagination(files)
        {
          per_page: -1,
          item_count: -1,
          current_page: arguments[:page],
          total_pages: files.size
        }
      end

      def list_events_from_database(page, size)
        events = Event
                  .select('id, data, event_type as type, timestamp')
                  .where(recording_id: object.id)
                  .order('timestamp asc')
                  .page(page)
                  .per(size)

        {
          items: events.map(&:to_json),
          pagination: database_pagination(events, arguments)
        }
      end

      def database_pagination(events, arguments)
        {
          per_page: arguments[:size],
          item_count: events.total_count,
          current_page: arguments[:page],
          total_pages: events.total_pages
        }
      end
    end
  end
end
