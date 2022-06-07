# frozen_string_literal: true

module EventsService
  module Types
    class Error < Base
      def count
        query = sanitize_query(
          query_count,
          event.site_id,
          from_date
        )

        ClickHouse.connection.select_value(query)
      end

      def results
        # TODO
      end

      private

      def query_count
        <<-SQL
          SELECT COUNT(*)
          FROM events
          WHERE
            site_id = ? AND
            type = 100 AND
            timestamp / 1000 >= ? AND
            replaceOne(JSONExtractString(data, 'message'), 'Error: ', '') #{rule_expression}
        SQL
      end
    end
  end
end
