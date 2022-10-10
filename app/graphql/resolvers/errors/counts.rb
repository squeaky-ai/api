# frozen_string_literal: true

module Resolvers
  module Errors
    class Counts < Resolvers::Base
      type Types::Errors::Counts, null: false

      argument :error_id, ID, required: false
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(from_date:, to_date:, error_id: nil)
        date_format, group_type, group_range = Charts.date_groups(from_date, to_date, clickhouse: true)

        items = ClickHouse.connection.select_all(
          query(date_format, error_id, from_date, to_date)
        )

        {
          group_type:,
          group_range:,
          items:
        }
      end

      private

      def query(date_format, error_id, from_date, to_date)
        if error_id.nil?
          query_without_error_id(date_format, from_date, to_date)
        else
          query_with_error_id(date_format, error_id, from_date, to_date)
        end
      end

      def query_with_error_id(date_format, error_id, from_date, to_date)
        sql = <<-SQL
          SELECT
            COUNT(*) count,
            formatDateTime(toDate(timestamp / 1000), ?) date_key
          FROM
            error_events
          WHERE
            site_id = ? AND
            toDate(timestamp / 1000) BETWEEN ? AND ? AND
            message = ?
          GROUP BY date_key
          FORMAT JSON
        SQL

        variables = [
          date_format,
          object.id,
          from_date,
          to_date,
          Base64.decode64(error_id)
        ]

        ActiveRecord::Base.sanitize_sql_array([sql, *variables])
      end

      def query_without_error_id(date_format, from_date, to_date)
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

        ActiveRecord::Base.sanitize_sql_array([sql, *variables])
      end
    end
  end
end
