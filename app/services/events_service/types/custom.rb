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
        # TODO
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
