# frozen_string_literal: true

module Resolvers
  module Errors
    class Counts < Resolvers::Base
      type Types::Errors::Counts, null: false

      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(from_date:, to_date:)
        date_format, group_type, group_range = Charts.date_groups(from_date, to_date, clickhouse: true)

        sql = <<-SQL
          SELECT
            COUNT(*) count,
            formatDateTime(toDate(timestamp / 1000), ?) date_key
          FROM
            error_events
          WHERE
            site_id = ? AND
            toDate(timestamp / 1000) BETWEEN ? AND ?
          GROUP BY date_key
          FORMAT JSON
        SQL

        variables = [
          date_format,
          object.id,
          from_date,
          to_date
        ]

        query = ActiveRecord::Base.sanitize_sql_array([sql, *variables])
        items = ClickHouse.connection.select_all(query)

        {
          group_type:,
          group_range:,
          items:
        }
      end
    end
  end
end
