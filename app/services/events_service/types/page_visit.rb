# frozen_string_literal: true

module EventsService
  module Types
    class PageVisit < Base
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

      def href_expression
        value = rule['value']

        case rule['matcher']
        when 'equals'
          "= '#{value}'"
        when 'not_equals'
          "!= '#{value}'"
        when 'contains'
          "LIKE '%#{value}%'"
        when 'not_contains'
          "NOT LIKE '%#{value}%'"
        when 'starts_with'
          "LIKE '#{value}%'"
        end
      end

      def query_count
        <<-SQL
          SELECT COUNT(*)
          FROM events
          WHERE
            site_id = ? AND
            type = 4 AND
            timestamp / 1000 >= ? AND
            JSONExtractString(data, 'href') #{href_expression}
        SQL
      end
    end
  end
end
