# frozen_string_literal: true

module EventsService
  module Types
    class Error < Base
      def count
        <<-SQL
          SELECT
            COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM
            error_events
          WHERE
            site_id = :site_id AND
            replaceOne(message, 'Error: ', '') #{rule_expression} AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
      end

      def results
        <<-SQL
          SELECT
            uuid, recording_id, '#{event.name}' as event_name, timestamp
          FROM
            error_events
          WHERE
            site_id = :site_id AND
            replaceOne(message, 'Error: ', '') #{rule_expression} AND
            toDate(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
      end

      def counts
        <<-SQL
          SELECT
            COUNT(*) count, '#{event.id}' as id, formatDateTime(toDate(timestamp / 1000), :date_format) date_key
          FROM
            error_events
          WHERE
            site_id = :site_id AND
            replaceOne(message, 'Error: ', '') #{rule_expression} AND
            toDate(timestamp / 1000) BETWEEN :from_date AND :to_date
          GROUP BY date_key
        SQL
      end
    end
  end
end
