# frozen_string_literal: true

module Resolvers
  module Errors
    class Details < Resolvers::Base
      type Types::Errors::Details, null: true

      def resolve_with_timings
        error_details = result
        return nil unless error_details

        {
          id: object.error_id.strip,
          **error_details
        }
      end

      private

      def result
        sql = <<-SQL
          SELECT
            message,
            any(stack) stack,
            any(line_number) line_number,
            any(col_number) col_number,
            any(filename) filename,
            groupUniqArray(url) pages
          FROM error_events
          WHERE site_id = ? AND message = ? AND toDate(timestamp / 1000)::date BETWEEN ? AND ?
          GROUP BY message;
        SQL

        variables = [
          object.site.id,
          Base64.decode64(object.error_id),
          object.range.from,
          object.range.to
        ]

        query = ActiveRecord::Base.sanitize_sql_array([sql, *variables])
        ClickHouse.connection.select_one(query)
      end
    end
  end
end
