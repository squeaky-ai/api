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
          SELECT uuid as id, data, type, timestamp
          FROM events
          WHERE site_id = ? AND recording_id = ?
          ORDER BY timestamp ASC
          LIMIT ?
          OFFSET ?
        SQL

        query = ActiveRecord::Base.sanitize_sql_array(
          [
            sql,
            object.site_id,
            object.id,
            size,
            size * (page - 1)
          ]
        )

        ClickHouse.connection.select_all(query)
      end

      def total_count
        sql = <<-SQL
          SELECT COUNT(*)
          FROM events
          WHERE site_id = ? AND recording_id = ?
        SQL

        query = ActiveRecord::Base.sanitize_sql_array([sql, object.site_id, object.id])

        ClickHouse.connection.select_value(query)
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
