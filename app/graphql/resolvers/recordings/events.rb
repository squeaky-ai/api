# frozen_string_literal: true

module Resolvers
  module Recordings
    class Events < Resolvers::Base
      type Types::Recordings::Events, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 250

      def resolve_with_timings(page:, size:)
        results = events(page, size)
        results_total = total_count

        {
          items: results,
          pagination: pagination(results_total)
        }
      end

      private

      def events(page, size)
        sql = <<-SQL
          SELECT id, data, event_type as type, timestamp
          FROM events
          WHERE recording_id = ?
          ORDER BY timestamp ASC
          OFFSET ?
          LIMIT ?
        SQL

        Sql.execute(sql, [object.id, size * (page - 1), size])
      end

      def total_count
        sql = <<-SQL
          SELECT COUNT(*)
          FROM events
          WHERE recording_id = ?
        SQL

        Sql.execute(sql, [object.id]).first['count']
      end

      def pagination(results_total)
        {
          per_page: arguments[:size],
          item_count: results_total,
          current_page: arguments[:page],
          total_pages: (results_total.to_f / arguments[:size]).ceil
        }
      end
    end
  end
end
