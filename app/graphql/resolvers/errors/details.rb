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
          FROM
            error_events
          WHERE
            site_id = :site_id AND
            message = :message AND
            toDate(timestamp / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY message;
        SQL

        variables = {
          site_id: object.site.id,
          message: Base64.decode64(object.error_id),
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to
        }

        Sql::ClickHouse.select_one(sql, variables)
      end
    end
  end
end
