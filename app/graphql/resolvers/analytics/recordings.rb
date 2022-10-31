# frozen_string_literal: true

module Resolvers
  module Analytics
    class Recordings < Resolvers::Base
      type Types::Analytics::Recordings, null: false

      def resolve_with_timings # rubocop:disable Metrics/AbcSize
        sql = <<-SQL
          SELECT
            COUNT(*) count,
            formatDateTime(toDate(disconnected_at / 1000), ?) date_key
          FROM
            recordings
          WHERE
            site_id = ? AND
            toDate(disconnected_at / 1000)::date BETWEEN ? AND ?
          GROUP BY
            date_key
        SQL

        date_format, group_type, group_range = Charts.date_groups(object.range.from, object.range.to, clickhouse: true)

        variables = [
          date_format,
          object.site.id,
          object.range.from,
          object.range.to
        ]

        {
          group_type:,
          group_range:,
          items: Sql::ClickHouse.select_all(sql, variables)
        }
      end
    end
  end
end
