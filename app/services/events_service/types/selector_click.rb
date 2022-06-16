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
            type = 3 AND
            source = 2 AND
            JSONExtractString(data, 'selector') #{rule_expression} AND
            toDate(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
      end

      def results
        <<-SQL
          SELECT uuid, recording_id, '#{event.name}' as event_name, timestamp
          FROM events
          WHERE
            site_id = ? AND
            type = 3 AND
            source = 2 AND
            JSONExtractString(data, 'selector') #{rule_expression} AND
            toDate(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
      end
    end
  end
end
