# frozen_string_literal: true

module EventsService
  module Types
    class Custom < Base
      def count
        query = sanitize_query(
          query_count,
          event.site_id,
          from_date
        )

        ClickHouse.connection.select_value(query)
      end

      def results
        <<-SQL
          SELECT uuid, recording_id, '#{event.name}' as event_name, timestamp
          FROM events
          WHERE
            site_id = :site_id AND
            type = 101 AND
            JSONExtractString(data, 'name') #{rule_expression}
        SQL
      end

      private

      def query_count
        <<-SQL
          SELECT COUNT(*)
          FROM events
          WHERE
            site_id = ? AND
            type = 101 AND
            timestamp / 1000 >= ? AND
            JSONExtractString(data, 'name') #{rule_expression}
        SQL
      end
    end
  end
end
