# frozen_string_literal: true

module EventsService
  module Types
    class PageVisit < Base
      def count
        <<-SQL
          SELECT
            COUNT(*) count, '#{event_name}' as event_name, '#{event.id}' as event_id
          FROM
            page_events
          WHERE
            site_id = :site_id AND
            url #{rule_expression} AND
            toDateTime(exited_at / 1000) BETWEEN :from_date AND :to_date
        SQL
      end

      def results
        <<-SQL
          SELECT
            uuid, recording_id, '#{event_name}' as event_name, exited_at as timestamp, '{}' as data, 'web' as source
          FROM
            page_events
          WHERE
            site_id = :site_id AND
            url #{rule_expression} AND
            toDate(exited_at / 1000) BETWEEN :from_date AND :to_date
        SQL
      end

      def counts
        <<-SQL
          SELECT
            COUNT(*) count, '#{event.id}' as id, formatDateTime(toDate(exited_at / 1000), :date_format) date_key
          FROM
            page_events
          WHERE
            site_id = :site_id AND
            url #{rule_expression} AND
            toDate(exited_at / 1000) BETWEEN :from_date AND :to_date
          GROUP BY date_key
        SQL
      end
    end
  end
end
