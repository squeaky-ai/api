# frozen_string_literal: true

module Resolvers
  module Analytics
    class BounceCount < Resolvers::Base
      type Types::Analytics::BounceCounts, null: false

      def resolve_with_timings # rubocop:disable Metrics/AbcSize
        sql = <<-SQL
          SELECT
            COUNT(*) view_count,
            COUNT(exited_on) FILTER(WHERE bounced_on = true) bounce_rate_count,
            formatDateTime(toDate(exited_at / 1000), ?) date_key
          FROM
            page_events
          WHERE
            site_id = ? AND
            toDate(exited_at / 1000)::date BETWEEN ? AND ?
          GROUP BY date_key
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
