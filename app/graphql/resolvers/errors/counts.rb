# frozen_string_literal: true

module Resolvers
  module Errors
    class Counts < Resolvers::Base
      type Types::Errors::Counts, null: false

      argument :error_id, ID, required: false
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(from_date:, to_date:, error_id: nil)
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        date_format, group_type, group_range = Charts.date_groups(range.from, range.to, clickhouse: true)

        items = query(date_format, error_id, range)

        {
          group_type:,
          group_range:,
          items:
        }
      end

      private

      def query(date_format, error_id, range)
        if error_id.nil?
          query_without_error_id(date_format, range)
        else
          query_with_error_id(date_format, error_id, range)
        end
      end

      def query_with_error_id(date_format, error_id, range)
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
          range.from,
          range.to,
          Base64.decode64(error_id)
        ]

        Sql::ClickHouse.select_all(sql, variables)
      end

      def query_without_error_id(date_format, range)
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
          range.from,
          range.to
        ]

        Sql::ClickHouse.select_all(sql, variables)
      end
    end
  end
end
