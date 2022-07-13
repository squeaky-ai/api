# frozen_string_literal: true

module EventsService
  module Types
    class SelectorClick < Base
      def count
        <<-SQL
          SELECT COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM events
          WHERE
            site_id = :site_id AND
            type = #{Event::INCREMENTAL_SNAPSHOT} AND
            source = #{Event::IncrementalSource::MOUSE_INTERACTION} AND
            JSONExtractString(data, 'selector') #{rule_expression} AND
            toDateTime(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
      end

      def results
        <<-SQL
          SELECT uuid, recording_id, '#{event.name}' as event_name, timestamp
          FROM events
          WHERE
            site_id = :site_id AND
            type = #{Event::INCREMENTAL_SNAPSHOT} AND
            source = #{Event::IncrementalSource::MOUSE_INTERACTION} AND
            JSONExtractString(data, 'selector') #{rule_expression} AND
            toDate(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
      end

      def counts
        <<-SQL
          SELECT COUNT(*) count, '#{event.id}' as id, formatDateTime(toDate(timestamp / 1000), :date_format) date_key
          FROM events
          WHERE
            site_id = :site_id AND
            type = #{Event::INCREMENTAL_SNAPSHOT} AND
            source = #{Event::IncrementalSource::MOUSE_INTERACTION} AND
            JSONExtractString(data, 'selector') #{rule_expression} AND
            toDate(timestamp / 1000) BETWEEN :from_date AND :to_date
          GROUP BY date_key
        SQL
      end
    end
  end
end
