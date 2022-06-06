# frozen_string_literal: true

module EventsService
  module Types
    class PageVisit < Base
      def count
        query = sanitize_query(
          query_count,
          event.site_id,
          from_date,
          rule['value']
        )

        ClickHouse.connection.select_value(query)
      end

      def results
        # TODO
      end

      private

      def href_expression
        case rule['matcher']
        when 'equals'
          '='
        when 'not_equals'
          '!='
        when 'contains', 'not_contains', 'starts_with'
          'LIKE'
        end
      end

      def query_count
        <<-SQL
          SELECT COUNT(*)
          FROM events
          WHERE
            site_id = ? AND
            type = 4 AND
            timestamp / 1000 > ? AND
            JSONExtractString(data, 'href') #{href_expression} ?
        SQL
      end
    end
  end
end
