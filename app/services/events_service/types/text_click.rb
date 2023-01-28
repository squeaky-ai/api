# frozen_string_literal: true

module EventsService
  module Types
    class TextClick < Base
      def count
        <<-SQL
          SELECT
            COUNT(*) count,
            '#{event_name}' as event_name,
            '#{event.id}' as event_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            text #{rule_expression} AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
      end

      def results
        <<-SQL
          SELECT
            uuid,
            recording_id,
            '#{event_name}' as event_name,
            timestamp,
            '{}' as data,
            '#{EventCapture::WEB}' as source,
            null as visitor_id
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            text #{rule_expression} AND
            toDate(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
      end

      def counts
        <<-SQL
          SELECT
            COUNT(*) count,
            '#{event.id}' as id,
            formatDateTime(toDate(timestamp / 1000), :date_format) date_key
          FROM
            click_events
          WHERE
            site_id = :site_id AND
            text #{rule_expression} AND
            toDate(timestamp / 1000) BETWEEN :from_date AND :to_date
          GROUP BY date_key
        SQL
      end
    end
  end
end
