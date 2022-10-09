# frozen_string_literal: true

module Resolvers
  module Errors
    class Details < Resolvers::Base
      type Types::Errors::Details, null: true

      argument :error_id, ID, required: true

      def resolve_with_timings(error_id:)
        error_details = result(error_id)
        return nil unless error_details

        {
          id: error_id.strip,
          **error_details
        }
      end

      private

      def result(error_id)
        sql = <<-SQL
          SELECT
            message,
            any(stack) stack,
            any(line_number) line_number,
            any(col_number) col_number,
            any(filename) filename,
            groupUniqArray(url) pages,
            groupUniqArray(recording_id) recording_ids
          FROM error_events
          WHERE site_id = ? AND message = ?
          GROUP BY message;
        SQL

        variables = [
          object.id,
          Base64.decode64(error_id)
        ]

        query = ActiveRecord::Base.sanitize_sql_array([sql, *variables])
        ClickHouse.connection.select_one(query)
      end
    end
  end
end
