# frozen_string_literal: true

module EventsService
  module Types
    class Error < Base
      def count
        <<-SQL
          SELECT COUNT(*) count, '#{event.name}' as event_name, '#{event.id}' as event_id
          FROM events
          WHERE
            site_id = :site_id AND
            type = 100 AND
            replaceOne(JSONExtractString(data, 'message'), 'Error: ', '') #{rule_expression} AND
            toDate(timestamp / 1000) BETWEEN :from_date AND :to_date
        SQL
      end

      def results
        <<-SQL
          SELECT uuid, recording_id, '#{event.name}' as event_name, timestamp
          FROM events
          WHERE
            site_id = :site_id AND
            type = 100 AND
            replaceOne(JSONExtractString(data, 'message'), 'Error: ', '') #{rule_expression} AND
            toDate(timestamp / 1000) BETWEEN :from_date AND :to_date
          LIMIT :limit
        SQL
      end
    end
  end
end
